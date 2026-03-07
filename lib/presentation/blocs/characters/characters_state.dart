part of 'characters_cubit.dart';

enum CharactersStatus { initial, loading, success, failure }

class CharactersState extends Equatable {
  final CharactersStatus status;
  final List<Character> characters;
  final bool hasReachedMax;
  final String? errorMessage;

  const CharactersState({
    this.status = CharactersStatus.initial,
    this.characters = const [],
    this.hasReachedMax = false,
    this.errorMessage,
  });

  CharactersState copyWith({
    CharactersStatus? status,
    List<Character>? characters,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return CharactersState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, characters, hasReachedMax, errorMessage];
}