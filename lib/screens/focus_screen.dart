import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/providers/focus_provider.dart';
import 'package:focusflow/services/focus_service.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/widgets/breathing_ring.dart';
import 'package:focusflow/widgets/celebration_animation.dart';
import 'package:focusflow/widgets/glass_time_picker.dart';
import 'package:focusflow/widgets/glass_card.dart';
import 'package:focusflow/widgets/floating_glass_nav_bar.dart';
import 'package:focusflow/utils/motion_extensions.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  bool _showCustomTimePicker = false;
  bool _showCelebration = false;

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final focusService = context.watch<FocusService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = focusProvider.isRunning;
    final hasTimer = focusProvider.totalSeconds > 0;

    // Show celebration if timer just completed
    if (hasTimer && focusProvider.remainingSeconds == 0 && !_showCelebration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showCelebration = true);
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    DarkModeColors.darkBackground,
                    DarkModeColors.darkSurface,
                    DarkModeColors.darkPrimary.withValues(alpha: isRunning ? 0.15 : 0.05),
                  ]
                : [
                    LightModeColors.lightPrimary.withValues(alpha: isRunning ? 0.1 : 0.03),
                    LightModeColors.lightBackground,
                    LightModeColors.lightSecondary.withValues(alpha: isRunning ? 0.08 : 0.02),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              if (!_showCelebration)
                Column(
                  children: [
                    // Header
                    if (!isRunning)
                      Padding(
                        padding: AppSpacing.paddingLg,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                              ),
                              onPressed: () => context.go('/home'),
                            ),
                            Text(
                              'Focus Timer',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 300))
                          .slideY(begin: -0.1, end: 0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: AppSpacing.paddingXl,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (hasTimer) ...[
                                // Immersive timer display
                                _ImmersiveTimerDisplay(
                                  remainingSeconds: focusProvider.remainingSeconds,
                                  totalSeconds: focusProvider.totalSeconds,
                                  isRunning: isRunning,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 60),
                                // Controls
                                _PremiumTimerControls(
                                  isRunning: isRunning,
                                  onPlayPause: () {
                                    if (isRunning) {
                                      focusProvider.pauseTimer();
                                    } else {
                                      focusProvider.resumeTimer();
                                    }
                                  },
                                  onReset: () {
                                    focusProvider.resetTimer();
                                    setState(() => _showCelebration = false);
                                  },
                                  onComplete: () async {
                                    final userService = context.read<UserService>();
                                    final completedMinutes = (focusProvider.totalSeconds - focusProvider.remainingSeconds) ~/ 60;
                                    if (completedMinutes > 0 && userService.currentUser != null) {
                                      await focusService.completeSession(
                                        userService.currentUser!.id,
                                        completedMinutes,
                                      );
                                    }
                                    focusProvider.completeSession();
                                    setState(() => _showCelebration = true);
                                  },
                                  isDark: isDark,
                                )
                                    .animate()
                                    .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400))
                                    .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                              ] else ...[
                                // Preset selection
                                _PremiumPresets(
                                  onSelectDuration: (minutes) => focusProvider.startTimer(minutes),
                                  onCustomTime: () => setState(() => _showCustomTimePicker = true),
                                  isDark: isDark,
                                )
                                    .animate()
                                    .fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400))
                                    .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                              ],
                              const SizedBox(height: 40),
                              // Stats
                              _PremiumSessionStats(
                                todayMinutes: focusService.getTodayFocusMinutes(),
                                totalMinutes: focusService.getTotalFocusMinutes(),
                                todaySessions: focusService.getTodaySessions().length,
                                isDark: isDark,
                              )
                                  .animate()
                                  .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400))
                                  .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              // Celebration overlay
              if (_showCelebration)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: CelebrationAnimation(
                      onComplete: () {
                        setState(() => _showCelebration = false);
                        focusProvider.resetTimer();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 Focus session completed!',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 300)),
              // Custom time picker overlay
              if (_showCustomTimePicker)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: GlassTimePicker(
                          onTimeSelected: (minutes) {
                            setState(() => _showCustomTimePicker = false);
                            focusProvider.startTimer(minutes);
                          },
                          onCancel: () => setState(() => _showCustomTimePicker = false),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 300)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingGlassNavBar(currentIndex: 1),
    );
  }
}

// Immersive timer display with breathing ring and gradient glow
class _ImmersiveTimerDisplay extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isDark;

  const _ImmersiveTimerDisplay({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.isDark,
  });

  @override
  State<_ImmersiveTimerDisplay> createState() => _ImmersiveTimerDisplayState();
}

class _ImmersiveTimerDisplayState extends State<_ImmersiveTimerDisplay>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalSeconds > 0
        ? (widget.totalSeconds - widget.remainingSeconds) / widget.totalSeconds
        : 0.0;

    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final primaryColor = widget.isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary;
    final secondaryColor = widget.isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary;

    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _pulseController]),
      builder: (context, child) {
        final glowValue = widget.isRunning ? _glowController.value : 0.0;
        final pulseValue = widget.isRunning ? _pulseController.value : 0.0;

        return Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.isRunning
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4 + (glowValue * 0.3)),
                      blurRadius: 50 + (glowValue * 30),
                      spreadRadius: 10 + (glowValue * 10),
                    ),
                    BoxShadow(
                      color: secondaryColor.withValues(alpha: 0.2 + (glowValue * 0.2)),
                      blurRadius: 80 + (glowValue * 40),
                      spreadRadius: 5 + (glowValue * 5),
                    ),
                  ]
                : [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Breathing rings
              if (widget.isRunning) ...[
                BreathingRing(
                  size: 320,
                  color: primaryColor,
                  isActive: true,
                ),
                BreathingRing(
                  size: 280,
                  color: secondaryColor,
                  isActive: true,
                ),
              ],
              // Progress ring
              CustomPaint(
                size: const Size(320, 320),
                painter: _PremiumTimerPainter(
                  progress: progress,
                  backgroundColor: widget.isDark
                      ? DarkModeColors.darkSurfaceContainerHighest
                      : LightModeColors.lightSurfaceContainerHighest,
                  progressColor1: primaryColor,
                  progressColor2: secondaryColor,
                ),
              ),
              // Time display
              Transform.scale(
                scale: 1.0 + (pulseValue * 0.02),
                child: Text(
                  timeString,
                  style: GoogleFonts.inter(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: widget.isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                    letterSpacing: -2,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumTimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor1;
  final Color progressColor2;

  _PremiumTimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor1,
    required this.progressColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 24;
    const strokeWidth = 20.0;

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

      final sweepAngle = 2 * math.pi * progress;
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
  bool shouldRepaint(_PremiumTimerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.progressColor1 != progressColor1 ||
      oldDelegate.progressColor2 != progressColor2;
}

// Premium preset chips with spring animation
class _PremiumPresets extends StatelessWidget {
  final Function(int) onSelectDuration;
  final VoidCallback onCustomTime;
  final bool isDark;

  const _PremiumPresets({
    required this.onSelectDuration,
    required this.onCustomTime,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Select Duration',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                .withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _PresetChip(
              label: '5 min',
              minutes: 5,
              onTap: () => onSelectDuration(5),
              isDark: isDark,
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
            _PresetChip(
              label: '15 min',
              minutes: 15,
              onTap: () => onSelectDuration(15),
              isDark: isDark,
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 150), duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 150), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
            _PresetChip(
              label: '25 min',
              minutes: 25,
              onTap: () => onSelectDuration(25),
              isDark: isDark,
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
            _PresetChip(
              label: '45 min',
              minutes: 45,
              onTap: () => onSelectDuration(45),
              isDark: isDark,
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 250), duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 250), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
            _PresetChip(
              label: 'Custom',
              minutes: 0,
              onTap: onCustomTime,
              isDark: isDark,
              isCustom: true,
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
          ],
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final int minutes;
  final VoidCallback onTap;
  final bool isDark;
  final bool isCustom;

  const _PresetChip({
    required this.label,
    required this.minutes,
    required this.onTap,
    required this.isDark,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
          ),
        ),
      ),
    );
  }
}

// Premium timer controls
class _PremiumTimerControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;
  final VoidCallback onComplete;
  final bool isDark;

  const _PremiumTimerControls({
    required this.isRunning,
    required this.onPlayPause,
    required this.onReset,
    required this.onComplete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleOnTap(
          onTap: onReset,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? DarkModeColors.darkSurfaceVariant : LightModeColors.lightSurfaceVariant)
                  .withValues(alpha: 0.5),
            ),
            child: Icon(
              Icons.restart_alt_rounded,
              color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 24),
        ScaleOnTap(
          onTap: onPlayPause,
          child: Container(
            width: 88,
            height: 88,
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
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 24),
        ScaleOnTap(
          onTap: onComplete,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? DarkModeColors.darkSurfaceVariant : LightModeColors.lightSurfaceVariant)
                  .withValues(alpha: 0.5),
            ),
            child: Icon(
              Icons.check_rounded,
              color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

// Premium session stats
class _PremiumSessionStats extends StatelessWidget {
  final int todayMinutes;
  final int totalMinutes;
  final int todaySessions;
  final bool isDark;

  const _PremiumSessionStats({
    required this.todayMinutes,
    required this.totalMinutes,
    required this.todaySessions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.today_rounded,
            value: '$todayMinutes',
            label: 'Today',
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 50,
            color: (isDark ? DarkModeColors.darkOutline : LightModeColors.lightOutline)
                .withValues(alpha: 0.2),
          ),
          _StatItem(
            icon: Icons.check_circle_rounded,
            value: '$todaySessions',
            label: 'Sessions',
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 50,
            color: (isDark ? DarkModeColors.darkOutline : LightModeColors.lightOutline)
                .withValues(alpha: 0.2),
          ),
          _StatItem(
            icon: Icons.timer_rounded,
            value: '$totalMinutes',
            label: 'Total',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
          size: 28,
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
