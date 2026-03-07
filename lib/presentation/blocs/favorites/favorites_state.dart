part of 'favorites_cubit.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<Character> favorites;
  final SortType? sortType;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.sortType,
    this.errorMessage,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Character>? favorites,
    SortType? sortType,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      sortType: sortType ?? this.sortType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favorites, sortType, errorMessage];
}