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
    if (isClosed) return;

    // Защита от повторной загрузки
    if (state.status == CharactersStatus.loading && !refresh) return;
    if (_hasReachedMax && !refresh) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasReachedMax = false;

        // Обновляем state с новыми фильтрами (включая null)
        // Сбрасываем lastToggledCharacter при обновлении списка
        emit(CharactersState(
          status: CharactersStatus.loading,
          characters: const [],
          hasReachedMax: false,
          statusFilter: status,      // Может быть null - это сброс!
          genderFilter: gender,      // Может быть null - это сброс!
          searchQuery: searchQuery ?? state.searchQuery,
          favorites: state.favorites, // Сохраняем избранное
        ));
      } else {
        emit(state.copyWith(
          status: CharactersStatus.loading,
          clearLastToggled: true, // Сбрасываем при пагинации
        ));
      }

      // Делаем запрос с текущими фильтрами из state
      final characters = await _repository.getCharacters(
        page: _currentPage,
        searchQuery: state.searchQuery,
        status: state.statusFilter,
        gender: state.genderFilter,
      );

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
        clearLastToggled: true, // Сбрасываем после загрузки
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CharactersStatus.failure,
        errorMessage: e.toString(),
        clearLastToggled: true,
      ));
    }
  }

  void updateFilters({String? status, String? gender}) {
    print('updateFilters called: status=$status, gender=$gender');
    loadCharacters(
      refresh: true,
      status: status,
      gender: gender,
    );
  }

  void resetAllFilters() {
    print('resetAllFilters called');
    updateFilters(status: null, gender: null);
  }

  Future<void> toggleFavorite(Character character) async {
    await _repository.toggleFavorite(character);

    final updatedCharacters = state.characters.map((c) {
      if (c.id == character.id) {
        return c.copyWith(isFavorite: !c.isFavorite);
      }
      return c;
    }).toList();

    // Обновляем favorites set
    final updatedFavorites = Set<int>.from(state.favorites);
    if (updatedFavorites.contains(character.id)) {
      updatedFavorites.remove(character.id);
    } else {
      updatedFavorites.add(character.id);
    }

    emit(state.copyWith(
      characters: updatedCharacters,
      favorites: updatedFavorites,
      lastToggledCharacter: character,
    ));

    // Очищаем lastToggledCharacter после показа уведомления
    await Future.delayed(const Duration(milliseconds: 100));
    emit(state.copyWith(clearLastToggled: true));
  }

  void updateSearch(String query) {
    if (query.length >= 2 || query.isEmpty) {
      loadCharacters(refresh: true, searchQuery: query);
    }
  }
}