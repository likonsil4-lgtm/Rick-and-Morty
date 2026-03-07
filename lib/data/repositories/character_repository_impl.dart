import 'package:injectable/injectable.dart';

import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/remote/character_api_service.dart';

@Injectable(as: CharacterRepository)
class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterApiService _apiService;
  final DatabaseHelper _databaseHelper;

  CharacterRepositoryImpl(this._apiService, this._databaseHelper);

  @override
  Future<List<Character>> getCharacters({int page = 1}) async {
    final models = await _apiService.getCharacters(page: page);

    // Проверяем избранное для каждого персонажа
    final characters = await Future.wait(
      models.map((model) async {
        final isFav = await _databaseHelper.isFavorite(model.id);
        return model.toEntity(isFavorite: isFav);
      }),
    );

    return characters;
  }

  @override
  Future<List<Character>> getFavoriteCharacters() async {
    final favoritesData = await _databaseHelper.getFavorites();

    return favoritesData.map((data) => Character(
      id: data[DatabaseHelper.columnId] as int,
      name: data[DatabaseHelper.columnName] as String,
      status: data[DatabaseHelper.columnStatus] as String,
      species: data[DatabaseHelper.columnSpecies] as String,
      type: data[DatabaseHelper.columnType] as String,
      gender: data[DatabaseHelper.columnGender] as String,
      image: data[DatabaseHelper.columnImage] as String,
      location: data[DatabaseHelper.columnLocation] as String,
      origin: data[DatabaseHelper.columnOrigin] as String,
      isFavorite: true,
    )).toList();
  }

  @override
  Future<void> toggleFavorite(Character character) async {
    final isFav = await _databaseHelper.isFavorite(character.id);

    if (isFav) {
      await _databaseHelper.deleteFavorite(character.id);
    } else {
      await _databaseHelper.insertFavorite({
        DatabaseHelper.columnId: character.id,
        DatabaseHelper.columnName: character.name,
        DatabaseHelper.columnStatus: character.status,
        DatabaseHelper.columnSpecies: character.species,
        DatabaseHelper.columnType: character.type,
        DatabaseHelper.columnGender: character.gender,
        DatabaseHelper.columnImage: character.image,
        DatabaseHelper.columnLocation: character.location,
        DatabaseHelper.columnOrigin: character.origin,
      });
    }
  }

  @override
  Future<bool> isFavorite(int id) async {
    return await _databaseHelper.isFavorite(id);
  }
}