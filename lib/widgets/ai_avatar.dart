import 'package:flutter/material.dart';
import 'package:focusflow/theme.dart';

/// AI avatar with subtle motion animation
class AiAvatar extends StatefulWidget {
  final double size;
  final bool isThinking;

  const AiAvatar({
    super.key,
    this.size = 48,
    this.isThinking = false,
  });

  @override
  State<AiAvatar> createState() => _AiAvatarState();
}

class _AiAvatarState extends State<AiAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isThinking ? _pulseAnimation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                  isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                      .withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
              size: widget.size * 0.5,
            ),
          ),
        );
      },
    );
  }
}

