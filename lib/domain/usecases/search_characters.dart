import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/character.dart';
import '../repositories/character_repository.dart';

@injectable
class SearchCharacters implements UseCase<List<Character>, String> {
  final CharacterRepository repository;

  SearchCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(String query) async {
    return await repository.searchCharacters(query);
  }
}