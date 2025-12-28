import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:focusflow/theme.dart';

class ProgressRing extends StatefulWidget {
  final double progress;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(begin: _animation.value, end: widget.progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary;
    final secondaryColor = isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ProgressRingPainter(
                progress: _animation.value,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                progressColor1: primaryColor,
                progressColor2: secondaryColor,
              ),
            ),
            Text(
              '${_animation.value.toInt()}%',
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor1;
  final Color progressColor2;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor1,
    required this.progressColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final strokeWidth = 12.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [progressColor1, progressColor2, progressColor1],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * (progress / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
    oldDelegate.progress != progress ||
    oldDelegate.backgroundColor != backgroundColor ||
    oldDelegate.progressColor1 != progressColor1 ||
    oldDelegate.progressColor2 != progressColor2;
}
