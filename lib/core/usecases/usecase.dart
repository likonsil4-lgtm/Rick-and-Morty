import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaginationParams extends Equatable {
  final int page;
  final String? searchQuery;
  final String? status;
  final String? gender;

  const PaginationParams({
    this.page = 1,
    this.searchQuery,
    this.status,
    this.gender,
  });

  @override
  List<Object?> get props => [page, searchQuery, status, gender];
}