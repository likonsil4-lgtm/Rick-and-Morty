import '../entities/character.dart';

abstract class CharacterRepository {
  Future<List<Character>> getCharacters({
    int page = 1,
    String? searchQuery,
    String? status,
    String? gender,
  });

  Future<List<Character>> searchCharacters(String query);
  Future<List<Character>> getFavoriteCharacters();
  Future<void> toggleFavorite(Character character);
  Future<bool> isFavorite(int id);
}