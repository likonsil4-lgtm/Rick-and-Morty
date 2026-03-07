import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../blocs/characters/characters_cubit.dart';
import '../widgets/character_card.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CharactersCubit>().loadCharacters();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CharactersCubit>().loadCharacters();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<CharactersCubit>().loadCharacters(refresh: true);
        },
        child: BlocBuilder<CharactersCubit, CharactersState>(
          builder: (context, state) {
            if (state.status == CharactersStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CharactersCubit>().loadCharacters();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.characters.isEmpty && state.status == CharactersStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.characters.length
                  : state.characters.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.characters.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final character = state.characters[index];
                return CharacterCard(
                  character: character,
                  onFavoriteToggle: () {
                    context.read<CharactersCubit>().toggleFavorite(character);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}