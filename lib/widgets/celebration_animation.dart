import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';

/// Celebration animation for completed focus sessions
class CelebrationAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const CelebrationAnimation({
    super.key,
    required this.onComplete,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shimmerAnimation;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeOutCubic,
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    _scaleController.forward();
    _rotateController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _showButton = true);
        }
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _rotateAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                            .withValues(alpha: 0.3),
                        (isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary)
                            .withValues(alpha: 0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                            .withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '🎉',
                      style: GoogleFonts.inter(
                        fontSize: 80,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        // Achievement message with shimmer animation
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment(_shimmerAnimation.value - 1, 0),
                  end: Alignment(_shimmerAnimation.value, 0),
                  colors: [
                    isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                    isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                    isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              child: Text(
                'Focus Session\nComplete!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1.2,
                ),
              ),
            );
          },
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 500))
            .slideY(begin: 0.2, end: 0, delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
        const SizedBox(height: 16),
        Text(
          'You stayed focused and achieved your goal!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                .withValues(alpha: 0.8),
            height: 1.4,
          ),
        )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 500))
            .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 800), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
        if (_showButton) ...[
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              _scaleController.stop();
              _rotateController.stop();
              widget.onComplete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
              foregroundColor: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              'Done',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 1000), duration: const Duration(milliseconds: 400))
              .slideY(begin: 0.2, end: 0, delay: const Duration(milliseconds: 1000), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
        ],
      ],
    );
  }
}

