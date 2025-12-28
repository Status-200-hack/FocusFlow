import 'package:flutter/material.dart';
import 'package:focusflow/models/task_model.dart';
import 'package:focusflow/theme.dart';

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  final bool isSelected;
  final VoidCallback? onTap;

  const PriorityChip({
    super.key,
    required this.priority,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getPriorityColor(isDark);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getPriorityLabel(),
              style: context.textStyles.labelLarge?.copyWith(
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(bool isDark) {
    switch (priority) {
      case TaskPriority.high:
        return isDark ? DarkModeColors.priorityHigh : LightModeColors.priorityHigh;
      case TaskPriority.medium:
        return isDark ? DarkModeColors.priorityMedium : LightModeColors.priorityMedium;
      case TaskPriority.low:
        return isDark ? DarkModeColors.priorityLow : LightModeColors.priorityLow;
    }
  }

  String _getPriorityLabel() {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}
