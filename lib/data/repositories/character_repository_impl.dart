import 'package:injectable/injectable.dart';

import '../../core/network/network_info.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/local/character_local_datasource.dart';
import '../datasources/remote/character_api_service.dart';
import '../models/character_model.dart';

@Injectable(as: CharacterRepository)
class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterApiService _remote;
  final CharacterLocalDataSource _local;
  final NetworkInfo _networkInfo;

  CharacterRepositoryImpl(
      this._remote,
      this._local,
      this._networkInfo,
      );

  @override
  Future<List<Character>> getCharacters({
    int page = 1,
    String? searchQuery,
    String? status,
    String? gender,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getCharacters(
          page: page,
          name: searchQuery,
          status: status,
          gender: gender,
        );

        // Кешируем только первую страницу без фильтров
        if (page == 1 && searchQuery == null && status == null && gender == null) {
          await _local.cacheCharacters(models);
        }

        return await _enrichWithFavorites(models);
      } catch (e) {
        // Fallback на кеш при ошибке
        final cached = await _local.getCachedCharacters();
        if (cached.isNotEmpty) {
          return await _enrichWithFavorites(cached);
        }
        throw Exception('Failed to load characters: $e');
      }
    } else {
      // Оффлайн-режим
      final cached = await _local.getCachedCharacters();
      if (cached.isNotEmpty) {
        return await _enrichWithFavorites(cached);
      }
      throw Exception('No internet connection and no cached data');
    }
  }

  @override
  Future<List<Character>> searchCharacters(String query) async {
    if (query.isEmpty) return [];

    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getCharacters(name: query);
        return await _enrichWithFavorites(models);
      } catch (e) {
        throw Exception('Search failed: $e');
      }
    }
    throw Exception('No internet connection for search');
  }

  Future<List<Character>> _enrichWithFavorites(List<CharacterModel> models) async {
    return Future.wait(
      models.map((model) async {
        final isFav = await _local.isFavorite(model.id);
        return model.toEntity(isFavorite: isFav);
      }),
    );
  }

  @override
  Future<List<Character>> getFavoriteCharacters() async {
    try {
      final models = await _local.getCachedFavorites();
      return models.map((m) => m.toEntity(isFavorite: true)).toList();
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  @override
  Future<void> toggleFavorite(Character character) async {
    try {
      final model = CharacterModel(
        id: character.id,
        name: character.name,
        status: character.status,
        species: character.species,
        type: character.type,
        gender: character.gender,
        image: character.image,
        location: LocationModel(name: character.location),
        origin: LocationModel(name: character.origin),
      );

      if (character.isFavorite) {
        await _local.removeCachedFavorite(character.id);
      } else {
        await _local.cacheFavorite(model);
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(int id) async {
    return await _local.isFavorite(id);
  }
}