// Added pagination support
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/character.dart';
import '../../../domain/repositories/character_repository.dart';

part 'characters_state.dart';

@injectable
class CharactersCubit extends Cubit<CharactersState> {
  final CharacterRepository _repository;
  int _currentPage = 1;
  bool _hasReachedMax = false;

  CharactersCubit(this._repository) : super(const CharactersState());

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

      final characters = await _repository.getCharacters(
        page: _currentPage,
        searchQuery: searchQuery ?? state.searchQuery,
        status: status ?? state.statusFilter,
        gender: gender ?? state.genderFilter,
      );

      if (characters.isEmpty) {
        _hasReachedMax = true;
      } else {
        _currentPage++;
      }

      // Удаляем дубликаты по ID
      final allCharacters = refresh
          ? characters
          : _mergeWithoutDuplicates(state.characters, characters);

      emit(state.copyWith(
        status: CharactersStatus.success,
        characters: allCharacters,
        hasReachedMax: _hasReachedMax,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CharactersStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Объединяет списки, удаляя дубликаты по ID
  List<Character> _mergeWithoutDuplicates(
      List<Character> existing,
      List<Character> newCharacters,
      ) {
    final existingIds = existing.map((c) => c.id).toSet();
    final uniqueNew = newCharacters.where((c) => !existingIds.contains(c.id)).toList();
    return [...existing, ...uniqueNew];
  }

  Future<void> toggleFavorite(Character character) async {
    await _repository.toggleFavorite(character);

    final updatedCharacters = state.characters.map((c) {
      if (c.id == character.id) {
        return c.copyWith(isFavorite: !c.isFavorite);
      }
      return c;
    }).toList();

    emit(state.copyWith(characters: updatedCharacters));
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
int page = 1;
