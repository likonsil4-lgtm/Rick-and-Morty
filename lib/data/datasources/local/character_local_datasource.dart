import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/character_model.dart';
import 'database_helper.dart';

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

  @override
  Future<List<CharacterModel>> getCachedFavorites() async {
    final favoritesData = await _db.getFavorites();
    return favoritesData.map((data) => CharacterModel(
      id: data[DatabaseHelper.columnId] as int,
      name: data[DatabaseHelper.columnName] as String,
      status: data[DatabaseHelper.columnStatus] as String,
      species: data[DatabaseHelper.columnSpecies] as String,
      type: data[DatabaseHelper.columnType] as String,
      gender: data[DatabaseHelper.columnGender] as String,
      image: data[DatabaseHelper.columnImage] as String,
      location: LocationModel(name: data[DatabaseHelper.columnLocation] as String),
      origin: LocationModel(name: data[DatabaseHelper.columnOrigin] as String),
    )).toList();
  }

  @override
  Future<void> cacheFavorite(CharacterModel character) async {
    await _db.insertFavorite({
      DatabaseHelper.columnId: character.id,
      DatabaseHelper.columnName: character.name,
      DatabaseHelper.columnStatus: character.status,
      DatabaseHelper.columnSpecies: character.species,
      DatabaseHelper.columnType: character.type,
      DatabaseHelper.columnGender: character.gender,
      DatabaseHelper.columnImage: character.image,
      DatabaseHelper.columnLocation: character.location.name,
      DatabaseHelper.columnOrigin: character.origin.name,
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

abstract class CharacterLocalDataSource {
  Future<List<CharacterModel>> getCachedCharacters();
  Future<void> cacheCharacters(List<CharacterModel> characters);
  Future<List<CharacterModel>> getCachedFavorites();
  Future<void> cacheFavorite(CharacterModel character);
  Future<void> removeCachedFavorite(int id);
  Future<bool> isFavorite(int id);
  Future<void> clearCache();
}