import 'package:flutter/material.dart';
import 'package:focusflow/theme.dart';

/// Gradient shimmer effect for "thinking" state
class ThinkingShimmer extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const ThinkingShimmer({
    super.key,
    required this.child,
    this.isActive = false,
  });

  @override
  State<ThinkingShimmer> createState() => _ThinkingShimmerState();
}

class _ThinkingShimmerState extends State<ThinkingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    if (widget.isActive) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(ThinkingShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
        _shimmerController.reset();
      }
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                (isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface)
                    .withValues(alpha: 0.3),
                isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                (isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface)
                    .withValues(alpha: 0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

