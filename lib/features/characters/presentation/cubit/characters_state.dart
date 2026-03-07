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

  const CharactersState({
    this.status = CharactersStatus.initial,
    this.characters = const [],
    this.hasReachedMax = false,
    this.errorMessage,
    this.searchQuery,
    this.statusFilter,
    this.genderFilter,
  });

  CharactersState copyWith({
    CharactersStatus? status,
    List<Character>? characters,
    bool? hasReachedMax,
    String? errorMessage,
    String? searchQuery,
    String? statusFilter,
    String? genderFilter,
  }) {
    return CharactersState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      genderFilter: genderFilter ?? this.genderFilter,
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
  ];
}