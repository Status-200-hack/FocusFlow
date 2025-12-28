import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/widgets/glass_card.dart';

/// Visual representation of streak/achievements
class StreakVisual extends StatelessWidget {
  final int streak;
  final int totalAchievements;
  final bool isDark;

  const StreakVisual({
    super.key,
    required this.streak,
    required this.totalAchievements,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streak Day Streak',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep it going! 🔥',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: (isDark
                                ? DarkModeColors.darkOnSurfaceVariant
                                : LightModeColors.lightOnSurfaceVariant)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AchievementBadge(
                icon: Icons.emoji_events_rounded,
                label: 'Achievements',
                count: totalAchievements,
                isDark: isDark,
              ),
              _AchievementBadge(
                icon: Icons.star_rounded,
                label: 'Level',
                count: (streak ~/ 7) + 1,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isDark;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: (isDark ? DarkModeColors.darkSurfaceVariant : LightModeColors.lightSurfaceVariant)
            .withValues(alpha: 0.5),
        border: Border.all(
          color: (isDark ? DarkModeColors.darkOutline : LightModeColors.lightOutline)
              .withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: (isDark
                          ? DarkModeColors.darkOnSurfaceVariant
                          : LightModeColors.lightOnSurfaceVariant)
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

