import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/services/task_service.dart';
import 'package:focusflow/services/focus_service.dart';
import 'package:focusflow/providers/theme_provider.dart';
import 'package:focusflow/widgets/animated_avatar_ring.dart';
import 'package:focusflow/widgets/counting_stat_card.dart';
import 'package:focusflow/widgets/streak_visual.dart';
import 'package:focusflow/widgets/morphing_theme_toggle.dart';
import 'package:focusflow/widgets/premium_settings_tile.dart';
import 'package:focusflow/widgets/floating_glass_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  int _calculateStreak(FocusService focusService) {
    // Calculate streak based on consecutive days with focus sessions
    final sessions = focusService.sessions;
    if (sessions.isEmpty) return 0;

    final now = DateTime.now();
    int streak = 0;
    DateTime currentDate = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 365; i++) {
      final hasSession = sessions.any((session) {
        final sessionDate = DateTime(
          session.completedAt.year,
          session.completedAt.month,
          session.completedAt.day,
        );
        return sessionDate.isAtSameMomentAs(currentDate);
      });

      if (hasSession) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateAchievements(TaskService taskService, FocusService focusService) {
    int achievements = 0;
    final completedTasks = taskService.tasks.where((t) => t.isCompleted).length;
    final totalFocusMinutes = focusService.getTotalFocusMinutes();

    if (completedTasks >= 1) achievements++;
    if (completedTasks >= 10) achievements++;
    if (completedTasks >= 50) achievements++;
    if (totalFocusMinutes >= 60) achievements++;
    if (totalFocusMinutes >= 300) achievements++;
    if (totalFocusMinutes >= 1000) achievements++;

    return achievements;
  }

  double _calculateProgress(TaskService taskService) {
    final totalTasks = taskService.tasks.length;
    if (totalTasks == 0) return 0.0;
    final completedTasks = taskService.tasks.where((t) => t.isCompleted).length;
    return completedTasks / totalTasks;
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final taskService = context.watch<TaskService>();
    final focusService = context.watch<FocusService>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = userService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completedTasks = taskService.tasks.where((t) => t.isCompleted).length;
    final totalTasks = taskService.tasks.length;
    final focusMinutes = focusService.getTotalFocusMinutes();
    final streak = _calculateStreak(focusService);
    final achievements = _calculateAchievements(taskService, focusService);
    final progress = _calculateProgress(taskService);

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
                    DarkModeColors.darkPrimary.withValues(alpha: 0.05),
                  ]
                : [
                    LightModeColors.lightPrimary.withValues(alpha: 0.03),
                    LightModeColors.lightBackground,
                    LightModeColors.lightSecondary.withValues(alpha: 0.02),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Avatar with progress ring
                AnimatedAvatarRing(
                  initial: user?.name.substring(0, 1).toUpperCase() ?? 'G',
                  size: 100,
                  progress: progress,
                  gradientColors: isDark
                      ? [DarkModeColors.darkPrimary, DarkModeColors.darkSecondary]
                      : [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 500))
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      delay: const Duration(milliseconds: 100),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 20),
                Text(
                  user?.name ?? 'Guest User',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                    letterSpacing: -1,
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400))
                    .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'guest@focusflow.app',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: (isDark
                            ? DarkModeColors.darkOnSurfaceVariant
                            : LightModeColors.lightOnSurfaceVariant)
                        .withValues(alpha: 0.7),
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 250), duration: const Duration(milliseconds: 400))
                    .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 250), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                const SizedBox(height: 32),
                // Streak and achievements
                StreakVisual(
                  streak: streak,
                  totalAchievements: achievements,
                  isDark: isDark,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500))
                    .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
                const SizedBox(height: 24),
                // Stat cards
                Row(
                  children: [
                    Expanded(
                      child: CountingStatCard(
                        icon: Icons.task_alt_rounded,
                        value: completedTasks,
                        label: 'Completed',
                        color: isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary,
                        isDark: isDark,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 500))
                          .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CountingStatCard(
                        icon: Icons.pending_actions_rounded,
                        value: totalTasks - completedTasks,
                        label: 'Pending',
                        color: isDark ? DarkModeColors.darkTertiary : LightModeColors.lightTertiary,
                        isDark: isDark,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 450), duration: const Duration(milliseconds: 500))
                          .slideY(begin: 0.1, end: 0, delay: const Duration(milliseconds: 450), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CountingStatCard(
                        icon: Icons.timer_rounded,
                        value: focusMinutes,
                        label: 'Focus (min)',
                        color: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                        isDark: isDark,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 500))
                          .slideX(begin: 0.1, end: 0, delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Settings section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 400))
                    .slideX(begin: -0.1, end: 0, delay: const Duration(milliseconds: 600), duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                PremiumSettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Theme',
                  subtitle: themeProvider.isDarkMode ? 'Dark mode' : 'Light mode',
                  trailing: MorphingThemeToggle(
                    isDark: isDark,
                    isDarkMode: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                  isDark: isDark,
                  animationDelay: 700,
                ),
                const SizedBox(height: 12),
                PremiumSettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  subtitle: 'Manage your notifications',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: (isDark
                            ? DarkModeColors.darkOnSurfaceVariant
                            : LightModeColors.lightOnSurfaceVariant)
                        .withValues(alpha: 0.5),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notifications settings coming soon',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  isDark: isDark,
                  animationDelay: 750,
                ),
                const SizedBox(height: 12),
                PremiumSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help with the app',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: (isDark
                            ? DarkModeColors.darkOnSurfaceVariant
                            : LightModeColors.lightOnSurfaceVariant)
                        .withValues(alpha: 0.5),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Help center coming soon',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  isDark: isDark,
                  animationDelay: 800,
                ),
                const SizedBox(height: 12),
                PremiumSettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  titleColor: isDark ? DarkModeColors.darkError : LightModeColors.lightError,
                  iconColor: isDark ? DarkModeColors.darkError : LightModeColors.lightError,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        title: Text(
                          'Logout',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: GoogleFonts.inter(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(false),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pop(true),
                            child: Text(
                              'Logout',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: isDark ? DarkModeColors.darkError : LightModeColors.lightError,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      await context.read<UserService>().logout();
                      if (context.mounted) context.go('/login');
                    }
                  },
                  isDark: isDark,
                  animationDelay: 850,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FloatingGlassNavBar(currentIndex: 2),
    );
  }
}
