import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/character.dart';
import '../../../domain/repositories/character_repository.dart';

part 'favorites_state.dart';

enum SortType { name, status, species }

@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  final CharacterRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final favorites = await _repository.getFavoriteCharacters();
      emit(state.copyWith(
        status: FavoritesStatus.success,
        favorites: favorites,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> removeFromFavorites(Character character) async {
    await _repository.toggleFavorite(character);
    await loadFavorites(); // Перезагружаем список
  }

  void sortFavorites(SortType sortType) {
    final sorted = List<Character>.from(state.favorites);

    switch (sortType) {
      case SortType.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.status:
        sorted.sort((a, b) => a.status.compareTo(b.status));
        break;
      case SortType.species:
        sorted.sort((a, b) => a.species.compareTo(b.species));
        break;
    }

    emit(state.copyWith(
      favorites: sorted,
      sortType: sortType,
    ));
  }
}