import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../blocs/favorites/favorites_cubit.dart';
import '../widgets/animated_character_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    context.read<FavoritesCubit>().loadFavorites();
  }

  Future<void> _onRefresh() async {
    await context.read<FavoritesCubit>().loadFavorites();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible && !_isVisible) {
      // Страница стала видимой - обновляем данные
      _loadFavorites();
    }
    _isVisible = visible;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('favorites_page'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          actions: [
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
              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
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
                            const SizedBox(height: 16),
                            Text(
                              'Pull down to refresh',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _onRefresh,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8),
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final character = state.favorites[index];
                  return Dismissible(
                    key: Key(character.id.toString()),
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
      ),
    );
  }
}