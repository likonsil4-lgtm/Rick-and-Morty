
import '../entities/character.dart';
import '../repositories/character_repository.dart';

class GetCharacters {
  final CharacterRepository repository;

  GetCharacters(this.repository);

  Future<List<Character>> call({int page = 1}) async {
    return await repository.getCharacters(page: page);
  }
}
