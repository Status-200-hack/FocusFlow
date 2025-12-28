import 'package:flutter/material.dart';

/// Animated breathing ring that pulses in and out
class BreathingRing extends StatefulWidget {
  final double size;
  final Color color;
  final bool isActive;

  const BreathingRing({
    super.key,
    required this.size,
    required this.color,
    this.isActive = false,
  });

  @override
  State<BreathingRing> createState() => _BreathingRingState();
}

class _BreathingRingState extends State<BreathingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (widget.isActive) {
      _breathController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BreathingRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _breathController.repeat(reverse: true);
      } else {
        _breathController.stop();
        _breathController.reset();
      }
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        final scale = widget.isActive ? 1.0 + (_breathController.value * 0.15) : 1.0;
        final opacity = widget.isActive ? 0.3 + (_breathController.value * 0.2) : 0.2;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withValues(alpha: opacity),
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}

