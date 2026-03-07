import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum SnackbarType {
  success,    // Добавлено в избранное - зеленый портал
  error,      // Ошибка - красный портал
  info,       // Информация - синий портал
  remove,     // Удалено из избранного - оранжевый портал
}

class RickMortySnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _RickMortySnackbarWidget(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  static void showFavoriteAdded(BuildContext context, String characterName) {
    show(
      context: context,
      message: '$characterName added to favorites!',
      type: SnackbarType.success,
      actionLabel: 'UNDO',
      onAction: () {
        // Можно добавить логику отмены
      },
    );
  }

  static void showFavoriteRemoved(BuildContext context, String characterName) {
    show(
      context: context,
      message: '$characterName removed from favorites',
      type: SnackbarType.remove,
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context: context,
      message: message,
      type: SnackbarType.error,
      actionLabel: 'RETRY',
    );
  }
}

class _RickMortySnackbarWidget extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final VoidCallback onDismiss;

  const _RickMortySnackbarWidget({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_RickMortySnackbarWidget> createState() => _RickMortySnackbarWidgetState();
}

class _RickMortySnackbarWidgetState extends State<_RickMortySnackbarWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _portalController;
  late AnimationController _glitchController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _portalAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    // Анимация появления (скольжение сверху)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Анимация портала (пульсация)
    _portalController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Glitch эффект
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Запускаем анимацию появления
    _slideController.forward();

    // Таймер на автоматическое исчезновение
    _dismissTimer = Timer(widget.duration, _dismiss);

    // Запускаем glitch эффект периодически
    _startGlitchEffect();
  }

  void _startGlitchEffect() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _glitchController.forward().then((_) {
          _glitchController.reverse();
          if (mounted) {
            Future.delayed(const Duration(seconds: 2), _startGlitchEffect);
          }
        });
      }
    });
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _slideController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _portalController.dispose();
    _glitchController.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  Color get _portalColor {
    switch (widget.type) {
      case SnackbarType.success:
        return const Color(0xFF00FF00); // Кислотно-зеленый
      case SnackbarType.error:
        return const Color(0xFFFF0040); // Красный
      case SnackbarType.info:
        return const Color(0xFF00BFFF); // Голубой
      case SnackbarType.remove:
        return const Color(0xFFFFA500); // Оранжевый
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.star_rounded;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.info:
        return Icons.info_outline;
      case SnackbarType.remove:
        return Icons.delete_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: _dismiss,
          onHorizontalDragEnd: (_) => _dismiss(),
          child: AnimatedBuilder(
            animation: _portalController,
            builder: (context, child) {
              return CustomPaint(
                painter: _PortalPainter(
                  color: _portalColor,
                  progress: _portalController.value,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _portalColor.withOpacity(0.5 + (_portalController.value * 0.5)),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _portalColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Фоновый эффект портала
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _portalController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _SwirlPainter(
                                  color: _portalColor.withOpacity(0.1),
                                  progress: _portalController.value,
                                ),
                              );
                            },
                          ),
                        ),

                        // Glitch эффект
                        AnimatedBuilder(
                          animation: _glitchController,
                          builder: (context, child) {
                            final glitch = _glitchController.value * 4;
                            return Transform.translate(
                              offset: Offset(
                                math.sin(glitch * 10) * 2,
                                math.cos(glitch * 15) * 1,
                              ),
                              child: child,
                            );
                          },
                          child: Row(
                            children: [
                              // Иконка с анимацией
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _portalColor.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _portalColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        _icon,
                                        color: _portalColor,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),

                              // Текст
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getTitle(),
                                      style: TextStyle(
                                        color: _portalColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Кнопка действия
                              if (widget.actionLabel != null)
                                TextButton(
                                  onPressed: () {
                                    widget.onAction?.call();
                                    _dismiss();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: _portalColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: Text(
                                    widget.actionLabel!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.type) {
      case SnackbarType.success:
        return 'WUBBA LUBBA DUB DUB!';
      case SnackbarType.error:
        return 'OH GEEZ!';
      case SnackbarType.info:
        return 'HEY MORTY!';
      case SnackbarType.remove:
        return 'BYE BYE!';
    }
  }
}

// Кастомный painter для эффекта портала
class _PortalPainter extends CustomPainter {
  final Color color;
  final double progress;

  _PortalPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width > size.height ? size.width : size.height;

    // Рисуем кольца портала
    for (int i = 0; i < 3; i++) {
      final radius = maxRadius * (0.3 + (i * 0.2) + (progress * 0.1));
      final opacity = (1 - ((i + progress) / 4)).clamp(0.0, 1.0) * 0.3;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + (i * 1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter для завихрений внутри портала
class _SwirlPainter extends CustomPainter {
  final Color color;
  final double progress;

  _SwirlPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final startAngle = (i * 72 + (progress * 360)) * (3.14159 / 180);
      final endAngle = startAngle + 1.5;

      path.addArc(
        Rect.fromCenter(center: center, width: 40 + (i * 15), height: 40 + (i * 15)),
        startAngle,
        endAngle,
      );

      final paint = Paint()
        ..color = color.withOpacity(0.1 - (i * 0.02))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => true;
}