part of 'characters_cubit.dart';

enum CharactersStatus { initial, loading, success, failure }

class CharactersState extends Equatable {
  final List<Character> characters;
  final CharactersStatus status;
  final bool hasReachedMax;
  final String? errorMessage;
  final String searchQuery;
  final String? statusFilter;
  final String? genderFilter;
  final Set<int> favorites;
  final Character? lastToggledCharacter;

  const CharactersState({
    this.characters = const [],
    this.status = CharactersStatus.initial,
    this.hasReachedMax = false,
    this.errorMessage,
    this.searchQuery = '',
    this.statusFilter,
    this.genderFilter,
    this.favorites = const {},
    this.lastToggledCharacter,
  });

  CharactersState copyWith({
    List<Character>? characters,
    CharactersStatus? status,
    bool? hasReachedMax,
    String? errorMessage,
    String? searchQuery,
    String? statusFilter,
    String? genderFilter,
    Set<int>? favorites,
    Character? lastToggledCharacter,
    bool clearLastToggled = false,
  }) {
    return CharactersState(
      characters: characters ?? this.characters,
      status: status ?? this.status,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      genderFilter: genderFilter ?? this.genderFilter,
      favorites: favorites ?? this.favorites,
      lastToggledCharacter: clearLastToggled
          ? null
          : (lastToggledCharacter ?? this.lastToggledCharacter),
    );
  }

  @override
  List<Object?> get props => [
    characters,
    status,
    hasReachedMax,
    errorMessage,
    searchQuery,
    statusFilter,
    genderFilter,
    favorites,
    lastToggledCharacter,
  ];
}