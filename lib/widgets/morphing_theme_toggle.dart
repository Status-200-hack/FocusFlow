import 'package:flutter/material.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/widgets/glass_card.dart';

/// Theme toggle with smooth morph animation
class MorphingThemeToggle extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;
  final bool isDarkMode;

  const MorphingThemeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
    required this.isDarkMode,
  });

  @override
  State<MorphingThemeToggle> createState() => _MorphingThemeToggleState();
}

class _MorphingThemeToggleState extends State<MorphingThemeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _morphAnimation = Tween<double>(
      begin: widget.isDarkMode ? 0.0 : 1.0,
      end: widget.isDarkMode ? 1.0 : 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    if (widget.isDarkMode) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MorphingThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _morphAnimation = Tween<double>(
        begin: oldWidget.isDarkMode ? 1.0 : 0.0,
        end: widget.isDarkMode ? 1.0 : 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOutCubic,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.isDarkMode),
      child: GlassCard(
        borderRadius: 28,
        padding: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _morphAnimation,
          builder: (context, child) {
            return Container(
              width: 64,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.lerp(
                      widget.isDark
                          ? DarkModeColors.darkSurfaceVariant
                          : LightModeColors.lightSurfaceVariant,
                      widget.isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                      _morphAnimation.value,
                    )!,
                    Color.lerp(
                      widget.isDark
                          ? DarkModeColors.darkSurfaceVariant
                          : LightModeColors.lightSurfaceVariant,
                      widget.isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary,
                      _morphAnimation.value,
                    )!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                        .withValues(alpha: 0.3 * _morphAnimation.value),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                    left: _morphAnimation.value * 28,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        size: 16,
                        color: widget.isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

