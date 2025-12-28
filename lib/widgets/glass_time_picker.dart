import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusflow/theme.dart';
import 'package:focusflow/widgets/glass_card.dart';

/// Glass-styled time picker with dials for hours and minutes
class GlassTimePicker extends StatefulWidget {
  final Function(int minutes) onTimeSelected;
  final VoidCallback onCancel;

  const GlassTimePicker({
    super.key,
    required this.onTimeSelected,
    required this.onCancel,
  });

  @override
  State<GlassTimePicker> createState() => _GlassTimePickerState();
}

class _GlassTimePickerState extends State<GlassTimePicker> {
  final TextEditingController _hoursController = TextEditingController(text: '0');
  final TextEditingController _minutesController = TextEditingController(text: '25');
  final FocusNode _hoursFocus = FocusNode();
  final FocusNode _minutesFocus = FocusNode();

  int _selectedMinutes = 25;
  int _selectedHours = 0;

  @override
  void initState() {
    super.initState();
    _hoursController.addListener(_onHoursChanged);
    _minutesController.addListener(_onMinutesChanged);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _hoursFocus.dispose();
    _minutesFocus.dispose();
    super.dispose();
  }

  void _onHoursChanged() {
    final text = _hoursController.text;
    if (text.isEmpty) {
      setState(() => _selectedHours = 0);
      return;
    }
    final value = int.tryParse(text) ?? 0;
    if (value >= 0 && value <= 23) {
      setState(() => _selectedHours = value);
    } else if (value > 23) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _hoursController.text = '23';
          _hoursController.selection = TextSelection.fromPosition(
            TextPosition(offset: _hoursController.text.length),
          );
          setState(() => _selectedHours = 23);
        }
      });
    }
  }

  void _onMinutesChanged() {
    final text = _minutesController.text;
    if (text.isEmpty) {
      setState(() => _selectedMinutes = 0);
      return;
    }
    final value = int.tryParse(text) ?? 0;
    if (value >= 0 && value <= 59) {
      setState(() => _selectedMinutes = value);
    } else if (value > 59) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _minutesController.text = '59';
          _minutesController.selection = TextSelection.fromPosition(
            TextPosition(offset: _minutesController.text.length),
          );
          setState(() => _selectedMinutes = 59);
        }
      });
    }
  }

  int get totalMinutes => (_selectedHours * 60) + _selectedMinutes;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GlassCard(
          borderRadius: 32,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Custom Time',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                ),
              ),
              const SizedBox(height: 24),
              // Time display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (isDark ? DarkModeColors.darkSurfaceVariant : LightModeColors.lightSurfaceVariant)
                      .withValues(alpha: 0.5),
                ),
                child: Text(
                  '${_selectedHours.toString().padLeft(2, '0')}:${_selectedMinutes.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Hours and Minutes input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: _TimeInput(
                      label: 'Hours',
                      controller: _hoursController,
                      focusNode: _hoursFocus,
                      max: 23,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: _TimeInput(
                      label: 'Minutes',
                      controller: _minutesController,
                      focusNode: _minutesFocus,
                      max: 59,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: (isDark ? DarkModeColors.darkOutline : LightModeColors.lightOutline)
                              .withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: totalMinutes > 0 ? () => widget.onTimeSelected(totalMinutes) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary,
                        foregroundColor: isDark ? DarkModeColors.darkOnPrimary : LightModeColors.lightOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Start',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutBack);
  }
}

class _TimeInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int max;
  final bool isDark;

  const _TimeInput({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.max,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (isDark ? DarkModeColors.darkSurfaceVariant : LightModeColors.lightSurfaceVariant)
                .withValues(alpha: 0.3),
            border: Border.all(
              color: focusNode.hasFocus
                  ? (isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary)
                  : (isDark ? DarkModeColors.darkOutline : LightModeColors.lightOutline)
                      .withValues(alpha: 0.1),
              width: focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              hintText: '00',
              hintStyle: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                    .withValues(alpha: 0.3),
              ),
            ),
            onChanged: (value) {
              // Allow empty for better UX
              if (value.isEmpty) return;
              
              // Only allow digits
              if (!RegExp(r'^\d+$').hasMatch(value)) {
                final filtered = value.replaceAll(RegExp(r'[^\d]'), '');
                controller.value = TextEditingValue(
                  text: filtered,
                  selection: TextSelection.collapsed(offset: filtered.length),
                );
                return;
              }
              
              final numValue = int.tryParse(value) ?? 0;
              if (numValue > max) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller.text.isNotEmpty) {
                    controller.text = max.toString();
                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length),
                    );
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

