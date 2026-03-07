import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../blocs/characters/characters_cubit.dart';
import '../widgets/character_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_bar.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Rick & Morty',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<CharactersCubit>().updateSearch(value);
                  },
                  onFilterTap: () => _showFilterSheet(context),
                ),
              ),
            ),
          ),
        ],
        body: BlocConsumer<CharactersCubit, CharactersState>(
          listener: (context, state) {
            if (state.status == CharactersStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Error'),
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () {
                      context.read<CharactersCubit>().loadCharacters();
                    },
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == CharactersStatus.failure &&
                state.characters.isEmpty) {
              return _buildErrorWidget(state.errorMessage);
            }

            if (state.characters.isEmpty && state.status == CharactersStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<CharactersCubit>().loadCharacters(refresh: true);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8),
                itemCount: state.hasReachedMax
                    ? state.characters.length
                    : state.characters.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.characters.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final character = state.characters[index];
                  return AnimatedCharacterCard(
                    character: character,
                    index: index,
                    onFavoriteToggle: () {
                      context.read<CharactersCubit>().toggleFavorite(character);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  Widget _buildErrorWidget(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CharactersCubit>().loadCharacters();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}