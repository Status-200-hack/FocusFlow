import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/widgets/glass_card.dart';

/// Premium glass chat bubble with animations
class GlassChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isAnimated;

  const GlassChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget bubble = GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
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
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                height: 1.5,
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? DarkModeColors.darkSecondary : LightModeColors.lightSecondary,
                    isDark ? DarkModeColors.darkTertiary : LightModeColors.lightTertiary,
                  ],
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                color: isDark ? DarkModeColors.darkOnSecondary : LightModeColors.lightOnSecondary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );

    if (isAnimated) {
      return bubble
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 300))
          .slideX(
            begin: isUser ? 0.2 : -0.2,
            end: 0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
    }

    return bubble;
  }
}

