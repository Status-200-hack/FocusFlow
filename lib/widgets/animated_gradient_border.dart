import 'package:flutter/material.dart';
import 'dart:ui';

/// Container with animated gradient border
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double borderRadius;
  final double borderWidth;
  final Duration animationDuration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    required this.colors,
    this.borderRadius = 24,
    this.borderWidth = 2,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: _controller.value * 2 * 3.14159,
              colors: widget.colors,
            ),
          ),
          padding: EdgeInsets.all(widget.borderWidth),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius - widget.borderWidth),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

