import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/character_model.dart';

abstract class CharacterLocalDataSource {
  Future<List<CharacterModel>> getCachedCharacters();
  Future<void> cacheCharacters(List<CharacterModel> characters);
  Future<List<CharacterModel>> getCachedFavorites();
  Future<void> cacheFavorite(CharacterModel character);
  Future<void> removeCachedFavorite(int id);
  Future<bool> isFavorite(int id);
  Future<void> clearCache();
}

@Injectable(as: CharacterLocalDataSource)
class CharacterLocalDataSourceImpl implements CharacterLocalDataSource {
  final SharedPreferences _prefs;
  final DatabaseHelper _db;

  static const String _cachedCharactersKey = 'CACHED_CHARACTERS';
  static const String _cacheTimeKey = 'CACHE_TIME';
  static const Duration _cacheValidity = Duration(hours: 1);

  CharacterLocalDataSourceImpl(this._prefs, this._db);

  @override
  Future<List<CharacterModel>> getCachedCharacters() async {
    final jsonString = _prefs.getString(_cachedCharactersKey);
    if (jsonString == null) return [];

    // Проверяем валидность кеша
    final cacheTime = _prefs.getInt(_cacheTimeKey);
    if (cacheTime != null) {
      final cachedDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      if (DateTime.now().difference(cachedDate) > _cacheValidity) {
        await clearCache();
        return [];
      }
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => CharacterModel.fromJson(json)).toList();
  }

  @override
  Future<void> cacheCharacters(List<CharacterModel> characters) async {
    final jsonList = characters.map((c) => c.toJson()).toList();
    await _prefs.setString(_cachedCharactersKey, json.encode(jsonList));
    await _prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_cachedCharactersKey);
    await _prefs.remove(_cacheTimeKey);
  }

  // Favorites используют SQLite (уже реализовано в DatabaseHelper)
  @override
  Future<List<CharacterModel>> getCachedFavorites() async {
    final favoritesData = await _db.getFavorites();
    return favoritesData.map((data) => CharacterModel(
      id: data['id'],
      name: data['name'],
      status: data['status'],
      species: data['species'],
      type: data['type'],
      gender: data['gender'],
      image: data['image'],
      location: LocationModel(name: data['location']),
      origin: LocationModel(name: data['origin']),
    )).toList();
  }

  @override
  Future<void> cacheFavorite(CharacterModel character) async {
    await _db.insertFavorite({
      'id': character.id,
      'name': character.name,
      'status': character.status,
      'species': character.species,
      'type': character.type,
      'gender': character.gender,
      'image': character.image,
      'location': character.location.name,
      'origin': character.origin.name,
    });
  }

  @override
  Future<void> removeCachedFavorite(int id) async {
    await _db.deleteFavorite(id);
  }

  @override
  Future<bool> isFavorite(int id) async {
    return await _db.isFavorite(id);
  }
}