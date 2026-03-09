import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==================== МЕНЕДЖЕР УВЕДОМЛЕНИЙ ====================

class SnackbarManager {
  static final SnackbarManager _instance = SnackbarManager._internal();
  factory SnackbarManager() => _instance;
  SnackbarManager._internal();

  OverlayEntry? _currentEntry;

  void show({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color color,
    bool isError = false,
  }) {
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (context) => PortalSnackBar(
        message: message,
        icon: icon,
        color: color,
        isError: isError,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }
}

// ==================== PUBLIC API ====================

// ==================== PUBLIC API ====================

class RickMortySnackbar {
  // Старый метод для совместимости
  static void showFavoriteToggled(
      BuildContext context,
      String characterName,
      bool isFavorite, // true = сейчас в избранном (добавлено), false = удалено
      ) {
    if (isFavorite) {
      showFavoriteAdded(context, characterName);
    } else {
      showFavoriteRemoved(context, characterName);
    }
  }

  static void showFavoriteAdded(BuildContext context, String characterName) {
    SnackbarManager().show(
      context: context,
      message: '$characterName добавлен в избранное',
      icon: Icons.favorite_rounded,
      color: const Color(0xFF00B894),
    );
    HapticFeedback.lightImpact();
  }

  static void showFavoriteRemoved(BuildContext context, String characterName) {
    SnackbarManager().show(
      context: context,
      message: '$characterName удалён из избранного',
      icon: Icons.heart_broken_outlined,
      color: const Color(0xFF6C5CE7),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    SnackbarManager().show(
      context: context,
      message: message,
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF00CEC9), // Бирюзовый
    );
    HapticFeedback.mediumImpact();
  }

  static void showError(BuildContext context, String message) {
    SnackbarManager().show(
      context: context,
      message: message,
      icon: Icons.error_outline_rounded,
      color: const Color(0xFFFF6B6B), // Красный
      isError: true,
    );
    HapticFeedback.heavyImpact();
  }

  static void showPortalOpened(BuildContext context) {
    SnackbarManager().show(
      context: context,
      message: 'Портал открыт! Wubba Lubba Dub Dub!',
      icon: Icons.auto_fix_high_rounded,
      color: const Color(0xFF00B894),
    );
  }
}

// ==================== WIDGET ====================

class PortalSnackBar extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final bool isError;
  final VoidCallback onDismiss;

  const PortalSnackBar({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    this.isError = false,
    required this.onDismiss,
  });

  @override
  State<PortalSnackBar> createState() => _PortalSnackBarState();
}

class _PortalSnackBarState extends State<PortalSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
    _scheduleDismiss();
  }

  void _scheduleDismiss() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) _dismiss();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color,
                        widget.color.withOpacity(0.85),
                        const Color(0xFF2D3436),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Иконка с портальным свечением
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Текст
                      Expanded(
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.isError ? 'ОШИБКА!' : 'ПОРТАЛ АКТИВЕН',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Кнопка закрытия
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _dismiss,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}