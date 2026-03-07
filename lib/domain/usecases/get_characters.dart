import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/character.dart';
import '../repositories/character_repository.dart';

@injectable
class GetCharacters implements UseCase<List<Character>, PaginationParams> {
  final CharacterRepository repository;

  GetCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(PaginationParams params) async {
    return await repository.getCharacters(
      page: params.page,
      searchQuery: params.searchQuery,
      status: params.status,
      gender: params.gender,
    );
  }
}