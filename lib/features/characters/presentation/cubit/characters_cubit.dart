
import 'package:flutter_bloc/flutter_bloc.dart';

class CharactersState {}

class CharactersLoading extends CharactersState {}

class CharactersLoaded extends CharactersState {
  final List characters;
  final bool hasReachedMax;

  CharactersLoaded(this.characters, {this.hasReachedMax = false});
}

class CharactersCubit extends Cubit<CharactersState> {
  CharactersCubit() : super(CharactersLoading());

  int page = 1;
  bool loadingMore = false;

  Future<void> loadCharacters() async {
    // TODO call usecase
  }

  Future<void> loadMore() async {
    if (loadingMore) return;

    loadingMore = true;
    page++;
    // TODO call pagination usecase
    loadingMore = false;
  }
}
