import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusflow/theme.dart';

/// Motion system extensions for consistent animations across the app
extension MotionExtensions on Widget {
  /// Page entry animation: fade + slide up
  Widget pageEnter({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return animate()
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: AppAnimations.smooth,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          delay: delay,
          duration: duration,
          curve: AppAnimations.smooth,
        );
  }

  /// Staggered list item animation
  Widget staggerList({
    required int index,
    Duration staggerDelay = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return animate()
        .fadeIn(
          delay: staggerDelay * index,
          duration: duration,
          curve: AppAnimations.smooth,
        )
        .slideX(
          begin: -0.1,
          end: 0,
          delay: staggerDelay * index,
          duration: duration,
          curve: AppAnimations.smooth,
        );
  }


  /// Fade in animation
  Widget fadeIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return animate()
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: AppAnimations.smooth,
        );
  }

  /// Slide in from bottom
  Widget slideUp({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return animate()
        .slideY(
          begin: 0.2,
          end: 0,
          delay: delay,
          duration: duration,
          curve: AppAnimations.smooth,
        )
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: AppAnimations.smooth,
        );
  }

  /// Slide in from right
  Widget slideInRight({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return animate()
        .slideX(
          begin: 0.2,
          end: 0,
          delay: delay,
          duration: duration,
          curve: AppAnimations.smooth,
        )
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: AppAnimations.smooth,
        );
  }

  /// Bounce in animation (for celebratory moments)
  Widget bounceIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return animate()
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: AppAnimations.smooth,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: delay,
          duration: duration,
          curve: AppAnimations.bounce,
        );
  }
}

/// Scale feedback widget for tap interactions
class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  const ScaleOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.snappy,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

