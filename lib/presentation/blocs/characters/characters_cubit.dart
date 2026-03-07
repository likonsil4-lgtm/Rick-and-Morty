import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/character.dart';
import '../../../domain/usecases/get_characters.dart';

part 'characters_state.dart';

@injectable
class CharactersCubit extends Cubit<CharactersState> {
  final GetCharacters _getCharacters;

  CharactersCubit(this._getCharacters) : super(const CharactersState());

  int _currentPage = 1;
  bool _hasReachedMax = false;

  Future<void> loadCharacters({
    bool refresh = false,
    String? searchQuery,
    String? status,
    String? gender,
  }) async {
    if (state.status == CharactersStatus.loading ||
        (_hasReachedMax && !refresh)) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasReachedMax = false;
        emit(state.copyWith(
          status: CharactersStatus.loading,
          characters: [],
          searchQuery: searchQuery,
          statusFilter: status,
          genderFilter: gender,
        ));
      } else {
        emit(state.copyWith(status: CharactersStatus.loading));
      }

      final result = await _getCharacters(PaginationParams(
        page: _currentPage,
        searchQuery: searchQuery ?? state.searchQuery,
        status: status ?? state.statusFilter,
        gender: gender ?? state.genderFilter,
      ));

      result.fold(
            (failure) => emit(state.copyWith(
          status: CharactersStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        )),
            (characters) {
          if (characters.isEmpty) {
            _hasReachedMax = true;
          } else {
            _currentPage++;
          }

          final allCharacters = refresh
              ? characters
              : [...state.characters, ...characters];

          emit(state.copyWith(
            status: CharactersStatus.success,
            characters: allCharacters,
            hasReachedMax: _hasReachedMax,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: CharactersStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Ошибка сервера. Проверьте подключение к интернету.';
      case NetworkFailure:
        return 'Нет подключения к интернету. Показаны кешированные данные.';
      case CacheFailure:
        return 'Ошибка кеша.';
      default:
        return 'Неизвестная ошибка';
    }
  }

  void updateFilters({String? status, String? gender}) {
    loadCharacters(refresh: true, status: status, gender: gender);
  }

  void updateSearch(String query) {
    if (query.length >= 2 || query.isEmpty) {
      loadCharacters(refresh: true, searchQuery: query);
    }
  }
}