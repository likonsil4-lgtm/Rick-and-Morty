
import '../entities/character.dart';
import '../repositories/character_repository.dart';

class SearchCharacters {
  final CharacterRepository repository;

  SearchCharacters(this.repository);

  Future<List<Character>> call(String query) async {
    return await repository.searchCharacters(query);
  }
}
