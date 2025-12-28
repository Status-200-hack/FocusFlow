import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable glassmorphism card with blur and subtle border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? tint;

  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.borderRadius = 20, this.tint});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseTint = tint ?? scheme.surface;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: baseTint.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.08),
                scheme.secondaryContainer.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
