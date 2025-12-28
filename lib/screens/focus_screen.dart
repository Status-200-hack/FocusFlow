import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:focusflow/theme.dart';
import 'package:focusflow/providers/focus_provider.dart';
import 'package:focusflow/services/focus_service.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/widgets/gradient_container.dart';
import 'package:focusflow/widgets/custom_button.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final focusService = context.watch<FocusService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/home'),
                  ),
                  Text('Focus Timer', style: context.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingXl,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimerDisplay(
                        remainingSeconds: focusProvider.remainingSeconds,
                        totalSeconds: focusProvider.totalSeconds,
                        isRunning: focusProvider.isRunning,
                      ),
                      const SizedBox(height: 60),
                      if (focusProvider.totalSeconds == 0)
                        _TimerPresets(
                          onSelectDuration: (minutes) => focusProvider.startTimer(minutes),
                        )
                      else
                        _TimerControls(
                          isRunning: focusProvider.isRunning,
                          onPlayPause: () {
                            if (focusProvider.isRunning) {
                              focusProvider.pauseTimer();
                            } else {
                              focusProvider.resumeTimer();
                            }
                          },
                          onReset: () async {
                            focusProvider.resetTimer();
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
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🎉 Focus session completed!')),
                              );
                            }
                          },
                        ),
                      const SizedBox(height: 60),
                      _SessionStats(
                        todayMinutes: focusService.getTodayFocusMinutes(),
                        totalMinutes: focusService.getTotalFocusMinutes(),
                        todaySessions: focusService.getTodaySessions().length,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(currentIndex: 1),
    );
  }
}

class _TimerDisplay extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;

  const _TimerDisplay({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
  });

  @override
  State<_TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<_TimerDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = widget.totalSeconds > 0
      ? (widget.totalSeconds - widget.remainingSeconds) / widget.totalSeconds
      : 0.0;

    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: widget.isRunning ? [
            BoxShadow(
              color: (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                .withValues(alpha: 0.3 + (_pulseController.value * 0.3)),
              blurRadius: 30 + (_pulseController.value * 20),
              spreadRadius: 5 + (_pulseController.value * 10),
            ),
          ] : [],
        ),
        child: CustomPaint(
          painter: _TimerPainter(
            progress: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            progressColor: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
          ),
          child: Center(
            child: Text(
              timeString,
              style: context.textStyles.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 56,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _TimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const strokeWidth = 12.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
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
  bool shouldRepaint(_TimerPainter oldDelegate) =>
    oldDelegate.progress != progress ||
    oldDelegate.backgroundColor != backgroundColor ||
    oldDelegate.progressColor != progressColor;
}

class _TimerPresets extends StatelessWidget {
  final Function(int) onSelectDuration;

  const _TimerPresets({required this.onSelectDuration});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'Select Duration',
        style: context.textStyles.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _PresetButton(label: '5 min', minutes: 5, onTap: () => onSelectDuration(5)),
          _PresetButton(label: '15 min', minutes: 15, onTap: () => onSelectDuration(15)),
          _PresetButton(label: '25 min', minutes: 25, onTap: () => onSelectDuration(25)),
          _PresetButton(label: '45 min', minutes: 45, onTap: () => onSelectDuration(45)),
        ],
      ),
    ],
  );
}

class _PresetButton extends StatelessWidget {
  final String label;
  final int minutes;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.minutes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  );
}

class _TimerControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;
  final VoidCallback onComplete;

  const _TimerControls({
    required this.isRunning,
    required this.onPlayPause,
    required this.onReset,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: onReset,
        icon: const Icon(Icons.restart_alt),
        iconSize: 32,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(20),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      const SizedBox(width: 20),
      FloatingActionButton.large(
        onPressed: onPlayPause,
        child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 36),
      ),
      const SizedBox(width: 20),
      IconButton(
        onPressed: onComplete,
        icon: const Icon(Icons.check),
        iconSize: 32,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(20),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    ],
  );
}

class _SessionStats extends StatelessWidget {
  final int todayMinutes;
  final int totalMinutes;
  final int todaySessions;

  const _SessionStats({
    required this.todayMinutes,
    required this.totalMinutes,
    required this.todaySessions,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: AppSpacing.paddingLg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.today,
            value: '$todayMinutes',
            label: 'Today (min)',
          ),
          Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline),
          _StatItem(
            icon: Icons.check_circle,
            value: '$todaySessions',
            label: 'Sessions',
          ),
          Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline),
          _StatItem(
            icon: Icons.timer,
            value: '$totalMinutes',
            label: 'Total (min)',
          ),
        ],
      ),
    ),
  );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 8),
      Text(
        value,
        style: context.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(
        label,
        style: context.textStyles.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () => context.go('/home'),
            ),
            _NavItem(
              icon: Icons.timer_rounded,
              label: 'Focus',
              isSelected: currentIndex == 1,
              onTap: () => context.go('/focus'),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: currentIndex == 2,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
