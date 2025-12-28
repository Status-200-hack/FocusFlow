import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/widgets/glass_card.dart';

/// Premium settings tile with icons and motion
class PremiumSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final bool isDark;
  final int animationDelay;

  const PremiumSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
    required this.isDark,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
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
                      (iconColor ?? (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary))
                          .withValues(alpha: 0.2),
                      (iconColor ?? (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary))
                          .withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor ??
                            (isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
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
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animationDelay), duration: const Duration(milliseconds: 400))
        .slideX(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: animationDelay),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }
}

