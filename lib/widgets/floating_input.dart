import 'package:flutter/material.dart';
import 'package:focusflow/theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium floating input field with animated focus glow
class FloatingInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const FloatingInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<FloatingInput> createState() => _FloatingInputState();
}

class _FloatingInputState extends State<FloatingInput>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _glowController;
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? DarkModeColors.darkPrimary : LightModeColors.lightPrimary;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowValue = _isFocused ? _glowController.value : 0.0;
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.xlAll,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3 + (glowValue * 0.2)),
                      blurRadius: 20 + (glowValue * 10),
                      spreadRadius: 2 + (glowValue * 2),
                    ),
                  ]
                : AppShadows.lightSm,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText && _obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            maxLines: widget.maxLines,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                    .withValues(alpha: 0.6),
              ),
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: _isFocused
                          ? primaryColor
                          : (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                              .withValues(alpha: 0.7),
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                            .withValues(alpha: 0.7),
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? DarkModeColors.darkSurfaceVariant.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.9),
              border: OutlineInputBorder(
                borderRadius: AppRadius.xlAll,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.xlAll,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.xlAll,
                borderSide: BorderSide(
                  color: primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.xlAll,
                borderSide: BorderSide(
                  color: isDark ? DarkModeColors.darkError : LightModeColors.lightError,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.xlAll,
                borderSide: BorderSide(
                  color: isDark ? DarkModeColors.darkError : LightModeColors.lightError,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              labelStyle: GoogleFonts.inter(
                fontSize: _isFocused || widget.controller.text.isNotEmpty ? 12 : 16,
                fontWeight: FontWeight.w500,
                color: _isFocused
                    ? primaryColor
                    : (isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant)
                        .withValues(alpha: 0.7),
              ),
              floatingLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

