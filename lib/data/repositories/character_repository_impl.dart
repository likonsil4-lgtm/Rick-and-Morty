import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
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
  Future<Either<Failure, List<Character>>> getCharacters({
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

        final characters = await _enrichWithFavorites(models);
        return Right(characters);
      } catch (e) {
        // Fallback на кеш при ошибке
        final cached = await _local.getCachedCharacters();
        if (cached.isNotEmpty) {
          final characters = await _enrichWithFavorites(cached);
          return Right(characters);
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // Оффлайн-режим
      final cached = await _local.getCachedCharacters();
      if (cached.isNotEmpty) {
        final characters = await _enrichWithFavorites(cached);
        return Right(characters);
      }
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Character>>> searchCharacters(String query) async {
    if (query.isEmpty) return const Right([]);

    if (await _networkInfo.isConnected) {
      try {
        final models = await _remote.getCharacters(name: query);
        final characters = await _enrichWithFavorites(models);
        return Right(characters);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    }
    return const Left(NetworkFailure());
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
  Future<Either<Failure, List<Character>>> getFavoriteCharacters() async {
    try {
      final models = await _local.getCachedFavorites();
      return Right(models.map((m) => m.toEntity(isFavorite: true)).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(Character character) async {
    try {
      final model = CharacterModel.fromEntity(character);
      if (character.isFavorite) {
        await _local.removeCachedFavorite(character.id);
      } else {
        await _local.cacheFavorite(model);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}