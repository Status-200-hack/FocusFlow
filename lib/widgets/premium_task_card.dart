import 'package:flutter/material.dart';
import 'package:focusflow/models/task_model.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/widgets/glass_card.dart';
import 'package:focusflow/utils/motion_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Premium task card with glass effect and color accents
class PremiumTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const PremiumTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(isDark);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: isDark ? DarkModeColors.darkError : LightModeColors.lightError,
          borderRadius: AppRadius.xlAll,
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: isDark ? DarkModeColors.darkOnError : LightModeColors.lightOnError,
          size: 28,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ScaleOnTap(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? DarkModeColors.darkOutline : LightModeColors.lightOutline)
                  .withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            child: Row(
            children: [
              // Priority accent bar
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: AppRadius.smAll,
                  boxShadow: [
                    BoxShadow(
                      color: priorityColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Checkbox with micro-animation
              ScaleOnTap(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? priorityColor : Colors.transparent,
                    border: Border.all(
                      color: priorityColor,
                      width: 2.5,
                    ),
                    borderRadius: AppRadius.mdAll,
                    boxShadow: task.isCompleted
                        ? [
                            BoxShadow(
                              color: priorityColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted
                            ? (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                                .withValues(alpha: 0.6)
                            : (isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface),
                        height: 1.3,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                              .withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM d').format(task.dueDate!),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Color _getPriorityColor(bool isDark) {
    switch (task.priority) {
      case TaskPriority.high:
        return isDark ? DarkModeColors.priorityHigh : LightModeColors.priorityHigh;
      case TaskPriority.medium:
        return isDark ? DarkModeColors.priorityMedium : LightModeColors.priorityMedium;
      case TaskPriority.low:
        return isDark ? DarkModeColors.priorityLow : LightModeColors.priorityLow;
    }
  }
}

