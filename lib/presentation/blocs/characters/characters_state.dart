part of 'characters_cubit.dart';

enum CharactersStatus { initial, loading, success, failure }

class CharactersState extends Equatable {
  final CharactersStatus status;
  final List<Character> characters;
  final bool hasReachedMax;
  final String? errorMessage;
  final String? searchQuery;
  final String? statusFilter;
  final String? genderFilter;

  // Новые поля для избранного
  final Set<int> favorites; // ID избранных персонажей для быстрого доступа
  final Character? lastToggledCharacter; // Последний переключённый персонаж (для SnackBar)

  const CharactersState({
    this.status = CharactersStatus.initial,
    this.characters = const [],
    this.hasReachedMax = false,
    this.errorMessage,
    this.searchQuery,
    this.statusFilter,
    this.genderFilter,
    this.favorites = const {}, // Пустое множество по умолчанию
    this.lastToggledCharacter, // null по умолчанию
  });

  CharactersState copyWith({
    CharactersStatus? status,
    List<Character>? characters,
    bool? hasReachedMax,
    String? errorMessage,
    String? searchQuery,
    String? statusFilter,
    String? genderFilter,
    Set<int>? favorites,
    Character? lastToggledCharacter,
    bool clearLastToggledCharacter = false, // Флаг для сброса
  }) {
    return CharactersState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      genderFilter: genderFilter ?? this.genderFilter,
      favorites: favorites ?? this.favorites,
      // Если clearLastToggledCharacter = true, сбрасываем в null
      lastToggledCharacter: clearLastToggledCharacter
          ? null
          : (lastToggledCharacter ?? this.lastToggledCharacter),
    );
  }

  @override
  List<Object?> get props => [
    status,
    characters,
    hasReachedMax,
    errorMessage,
    searchQuery,
    statusFilter,
    genderFilter,
    favorites,
    lastToggledCharacter,
  ];
}