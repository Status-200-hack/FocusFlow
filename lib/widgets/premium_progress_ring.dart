import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:focusflow/theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium progress ring with animated glow effect
class PremiumProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final String? label;

  const PremiumProgressRing({
    super.key,
    required this.progress,
    this.size = 180,
    this.label,
  });

  @override
  State<PremiumProgressRing> createState() => _PremiumProgressRingState();
}

class _PremiumProgressRingState extends State<PremiumProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PremiumProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary;
    final secondaryColor = isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary;

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _glowController]),
      builder: (context, child) {
        final glowValue = _glowController.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.2 + (glowValue * 0.2)),
                blurRadius: 30 + (glowValue * 20),
                spreadRadius: 5 + (glowValue * 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _PremiumProgressRingPainter(
                  progress: _progressAnimation.value,
                  backgroundColor: isDark
                      ? DarkModeColors.darkSurfaceContainerHighest
                      : LightModeColors.lightSurfaceContainerHighest,
                  progressColor1: primaryColor,
                  progressColor2: secondaryColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_progressAnimation.value.toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                      letterSpacing: -2,
                    ),
                  ),
                  if (widget.label != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.label!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor1;
  final Color progressColor2;

  _PremiumProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor1,
    required this.progressColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const strokeWidth = 16.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc with gradient
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
  bool shouldRepaint(_PremiumProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.progressColor1 != progressColor1 ||
      oldDelegate.progressColor2 != progressColor2;
}

