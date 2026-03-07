import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/favorites/favorites_cubit.dart';
import '../widgets/animated_character_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Сохраняем состояние при переключении табов

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  void _loadFavorites() {
    context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (sortType) {
              context.read<FavoritesCubit>().sortFavorites(sortType);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortType.name,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Sort by Name'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortType.status,
                child: Row(
                  children: [
                    Icon(Icons.circle),
                    SizedBox(width: 8),
                    Text('Sort by Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortType.species,
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Sort by Species'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.loading && state.favorites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add characters from the main list',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadFavorites,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FavoritesCubit>().loadFavorites();
            },
            child: ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final character = state.favorites[index];
                return Dismissible(
                  key: Key('fav_${character.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    context.read<FavoritesCubit>().removeFromFavorites(character);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${character.name} removed from favorites'),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            context.read<FavoritesCubit>().loadFavorites();
                          },
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: AnimatedCharacterCard(
                    character: character,
                    index: index,
                    onFavoriteToggle: () {
                      context.read<FavoritesCubit>().removeFromFavorites(character);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}