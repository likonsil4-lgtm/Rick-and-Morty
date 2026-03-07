import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../blocs/characters/characters_cubit.dart';
import '../widgets/animated_character_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_bar.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage>
    with TickerProviderStateMixin {
  late final AnimationController _appBarAnimationController;
  late final Animation<double> _appBarScaleAnimation;
  late final Animation<double> _titleFadeAnimation;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Для отслеживания направления скролла (показ/скрытие FAB)
  double _lastScrollOffset = 0;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
    context.read<CharactersCubit>().loadCharacters();
  }

  void _initAnimations() {
    _appBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _appBarScaleAnimation = CurvedAnimation(
      parent: _appBarAnimationController,
      curve: Curves.easeOutBack,
    );

    _titleFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _appBarAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _appBarAnimationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshOnReturn();
  }

  void _refreshOnReturn() {
    final cubit = context.read<CharactersCubit>();
    final state = cubit.state;

    if (state.characters.isNotEmpty && state.status == CharactersStatus.success) {
      cubit.loadCharacters(refresh: false);
    }
  }

  void _onScroll() {
    // Пагинация
    if (_isBottom) {
      context.read<CharactersCubit>().loadCharacters();
    }

    // Логика показа/скрытия FAB
    final currentOffset = _scrollController.offset;
    final isScrollingDown = currentOffset > _lastScrollOffset;
    final isScrollingUp = currentOffset < _lastScrollOffset;

    if (isScrollingDown && _isFabVisible && currentOffset > 100) {
      setState(() => _isFabVisible = false);
    } else if (isScrollingUp && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }

    _lastScrollOffset = currentOffset;
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.85); // Чуть раньше загружаем
  }

  @override
  void dispose() {
    _appBarAnimationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: colorScheme.surface,
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1 : 0,
          child: _buildScrollToTopFab(),
        ),
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            stretch: true,
            // Увеличил высоту чтобы вместить поиск без overflow
            expandedHeight: 160, // Было 140, добавил 20 пикселей
            elevation: 0,
            scrolledUnderElevation: 4,
            backgroundColor: colorScheme.surface.withOpacity(0.95),
            // Добавил toolbarHeight чтобы избежать конфликтов
            toolbarHeight: kToolbarHeight, // Стандартная высота AppBar (56)
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              title: AnimatedBuilder(
                animation: _titleFadeAnimation,
                builder: (context, child) => Opacity(
                  opacity: _titleFadeAnimation.value,
                  child: child,
                ),
                child: const Text(
                  'Rick & Morty',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              // Увеличил отступ снизу чтобы title не перекрывался поиском
              titlePadding: const EdgeInsets.only(left: 16, bottom: 80), // Было 60
              background: _buildAppBarBackground(colorScheme),
            ),
            bottom: PreferredSize(
              // Увеличил preferredSize чтобы точно вместить поиск
              preferredSize: const Size.fromHeight(76), // Было 70
              child: _buildSearchSection(colorScheme),
            ),
          ),
        ],
        body: BlocConsumer<CharactersCubit, CharactersState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(state, colorScheme),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBarBackground(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.secondary,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Декоративные круги (glassmorphism эффект)
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Сетка паттерн для sci-fi эффекта
          CustomPaint(
            size: Size.infinite,
            painter: _GridPatternPainter(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(ColorScheme colorScheme) {
    return Container(
      // Убрал вертикальные margin, оставил только padding внутри
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12), // bottom: 12 вместо 8
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -5,
          ),
        ],
      ),
      child: CustomSearchBar(
        controller: _searchController,
        onChanged: (value) {
          HapticFeedback.lightImpact();
          context.read<CharactersCubit>().updateSearch(value);
        },
        onFilterTap: () => _showFilterSheet(context),
      ),
    );
  }

  Widget _buildContent(CharactersState state, ColorScheme colorScheme) {
    if (state.status == CharactersStatus.failure && state.characters.isEmpty) {
      return _buildErrorWidget(state.errorMessage, colorScheme);
    }

    if (state.characters.isEmpty && state.status == CharactersStatus.loading) {
      return _buildShimmerLoading(colorScheme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await context.read<CharactersCubit>().loadCharacters(refresh: true);
      },
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      strokeWidth: 3,
      displacement: 80,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index >= state.characters.length) {
                    return _buildLoadingIndicator(state.hasReachedMax);
                  }

                  final character = state.characters[index];
                  return AnimatedCharacterCard(
                    character: character,
                    index: index,
                    onFavoriteToggle: () {
                      HapticFeedback.lightImpact();
                      context.read<CharactersCubit>().toggleFavorite(character);
                    },
                  );
                },
                childCount: state.hasReachedMax
                    ? state.characters.length
                    : state.characters.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Кастомный анимированный индикатор
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                        colorScheme.tertiary,
                        colorScheme.primary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Wubba Lubba Dub Dub!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading multiverse characters...',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool hasReachedMax) {
    if (hasReachedMax) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            '🚀 No more characters in this dimension',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String? message, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Анимированная иконка ошибки
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 50,
                      color: colorScheme.error,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Portal malfunction',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Something went wrong in the multiverse',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Красивая кнопка Retry
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.read<CharactersCubit>().loadCharacters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: colorScheme.primary.withOpacity(0.4),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToTopFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(Icons.arrow_upward_rounded),
      label: const Text('Top'),
    );
  }

  void _handleStateChanges(BuildContext context, CharactersState state) {
    if (state.status == CharactersStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.errorMessage ?? 'Error occurred',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Theme.of(context).colorScheme.error,
            onPressed: () {
              context.read<CharactersCubit>().loadCharacters();
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    // Успешное уведомление при добавлении в избранное
    if (state.lastToggledCharacter != null) {
      final isFavorite = state.favorites.contains(state.lastToggledCharacter!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isFavorite
                    ? 'Added to favorites'
                    : 'Removed from favorites',
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showFilterSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 30.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}