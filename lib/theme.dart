import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// SPACING SYSTEM
// =============================================================================

/// Premium spacing system with 8px base unit
class AppSpacing {
  // Base spacing values (8px grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Edge insets shortcuts
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  // Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);

  // Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);
}

// =============================================================================
// BORDER RADIUS SYSTEM
// =============================================================================

/// Premium border radius system (16-28px range as specified)
class AppRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
  static const double round = 9999.0; // Fully rounded

  // Common radius shortcuts
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get xxlAll => BorderRadius.circular(xxl);
  static BorderRadius get roundAll => BorderRadius.circular(round);
}

// =============================================================================
// ANIMATION SYSTEM
// =============================================================================

/// Premium animation constants for smooth, polished interactions
class AppAnimations {
  // Duration constants
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Curve constants
  static const Curve standard = Curves.easeInOut;
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve snappy = Curves.easeOutQuart;
  static const Curve gentle = Curves.easeInOutCubic;
  static const Curve bounce = Curves.easeOutBack;

  // Standard animation configuration
  static const Duration defaultDuration = normal;
  static const Curve defaultCurve = standard;
}

// =============================================================================
// SHADOW SYSTEM
// =============================================================================

/// Premium soft shadow system (no harsh elevation)
class AppShadows {
  // Light mode shadows
  static List<BoxShadow> get lightSm => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get lightMd => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get lightLg => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get lightXl => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: 0,
        ),
      ];

  // Dark mode shadows (more visible)
  static List<BoxShadow> get darkSm => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.20),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get darkMd => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.30),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get darkLg => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.40),
          blurRadius: 16,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get darkXl => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.50),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: 0,
        ),
      ];

  // Colored shadows for primary elements
  static List<BoxShadow> primaryGlow(Color color, {bool isDark = false}) => [
        BoxShadow(
          color: color.withValues(alpha: isDark ? 0.4 : 0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
          blurRadius: 40,
          offset: const Offset(0, 16),
          spreadRadius: 0,
        ),
      ];
}

// =============================================================================
// GLASSMORPHISM SYSTEM
// =============================================================================

/// Glassmorphism utilities for premium frosted glass effects
class AppGlass {
  /// Creates a glassmorphism decoration
  static BoxDecoration glassDecoration({
    required Color baseColor,
    required bool isDark,
    double borderRadius = 20,
    double blur = 10,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: baseColor.withValues(alpha: isDark ? 0.15 : 0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Creates a glassmorphism color filter
  static Color glassColor(Color baseColor, bool isDark) {
    return baseColor.withValues(alpha: isDark ? 0.15 : 0.7);
  }
}

// =============================================================================
// TEXT STYLE EXTENSIONS
// =============================================================================

/// Extension to add text style utilities to BuildContext
/// Access via context.textStyles
extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

/// Helper methods for common text style modifications
extension TextStyleExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text normal weight
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  /// Make text light
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Add custom color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add custom size
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// =============================================================================
// COLOR SYSTEM
// =============================================================================

/// Premium gradient color palette for light mode
class LightModeColors {
  // Primary: Rich Indigo-Purple gradient (premium feel)
  static const lightPrimary = Color(0xFF6366F1); // Indigo-500
  static const lightPrimaryLight = Color(0xFF818CF8); // Indigo-400
  static const lightPrimaryDark = Color(0xFF4C51BF); // Indigo-600
  static const lightPrimaryDarker = Color(0xFF4338CA); // Indigo-700
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFEEF2FF); // Softer, more premium
  static const lightOnPrimaryContainer = Color(0xFF312E81);

  // Primary gradient (for use in gradients)
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1), // Indigo-500
    Color(0xFF8B5CF6), // Purple-500
  ];

  // Secondary: Vibrant Teal-Cyan
  static const lightSecondary = Color(0xFF14B8A6); // Teal-500
  static const lightSecondaryLight = Color(0xFF5EEAD4); // Teal-300
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFFCCFBF1); // Soft teal

  // Tertiary: Warm Coral-Orange
  static const lightTertiary = Color(0xFFF97316); // Orange-500
  static const lightTertiaryLight = Color(0xFFFB923C); // Orange-400
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightTertiaryContainer = Color(0xFFFFEDD5); // Soft orange

  // Error colors (refined)
  static const lightError = Color(0xFFEF4444); // Red-500
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFEE2E2); // Soft red
  static const lightOnErrorContainer = Color(0xFF991B1B);

  // Surface and background: Premium off-whites with subtle warmth
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceDim = Color(0xFFF8FAFC); // Slate-50
  static const lightOnSurface = Color(0xFF0F172A); // Slate-900 (high contrast)
  static const lightOnSurfaceDim = Color(0xFF1E293B); // Slate-800
  static const lightBackground = Color(0xFFFAFBFC); // Almost white
  static const lightSurfaceVariant = Color(0xFFF1F5F9); // Slate-100
  static const lightSurfaceContainerHighest = Color(0xFFE2E8F0); // Slate-200
  static const lightOnSurfaceVariant = Color(0xFF475569); // Slate-600 (elevated contrast)

  // Outline and shadow (softer)
  static const lightOutline = Color(0xFFCBD5E1); // Slate-300
  static const lightOutlineVariant = Color(0xFFE2E8F0); // Slate-200
  static const lightShadow = Color(0xFF000000);
  static const lightInversePrimary = Color(0xFFA5B4FC);
  static const lightInverseSurface = Color(0xFF0F172A);
  static const lightOnInverseSurface = Color(0xFFF8FAFC);
  
  // Priority colors (refined palette)
  static const priorityHigh = Color(0xFFEF4444); // Red-500
  static const priorityMedium = Color(0xFFF59E0B); // Amber-500
  static const priorityLow = Color(0xFF10B981); // Emerald-500

  // Success, Warning, Info
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
}

/// Premium dark mode colors (refined for OLED and high contrast)
class DarkModeColors {
  // Primary: Lighter indigo for dark background (more vibrant)
  static const darkPrimary = Color(0xFFA5B4FC); // Indigo-300
  static const darkPrimaryLight = Color(0xFFC7D2FE); // Indigo-200
  static const darkPrimaryDark = Color(0xFF818CF8); // Indigo-400
  static const darkPrimaryDarker = Color(0xFF6366F1); // Indigo-500
  static const darkOnPrimary = Color(0xFF1E1B4B); // Indigo-900
  static const darkPrimaryContainer = Color(0xFF4C51BF); // Indigo-600
  static const darkOnPrimaryContainer = Color(0xFFE0E7FF); // Indigo-50

  // Primary gradient (for dark mode)
  static const List<Color> primaryGradient = [
    Color(0xFFA5B4FC), // Indigo-300
    Color(0xFFC4B5FD), // Purple-300
  ];

  // Secondary: Bright Teal-Cyan
  static const darkSecondary = Color(0xFF5EEAD4); // Teal-300
  static const darkSecondaryLight = Color(0xFF99F6E4); // Teal-200
  static const darkOnSecondary = Color(0xFF0F766E); // Teal-700
  static const darkSecondaryContainer = Color(0xFF134E4A); // Teal-800

  // Tertiary: Warm Coral-Orange
  static const darkTertiary = Color(0xFFFB923C); // Orange-400
  static const darkTertiaryLight = Color(0xFFFDBA74); // Orange-300
  static const darkOnTertiary = Color(0xFF7C2D12); // Orange-900
  static const darkTertiaryContainer = Color(0xFF9A3412); // Orange-800

  // Error colors (softer for dark)
  static const darkError = Color(0xFFFCA5A5); // Red-300
  static const darkOnError = Color(0xFF7F1D1D); // Red-900
  static const darkErrorContainer = Color(0xFF991B1B); // Red-800
  static const darkOnErrorContainer = Color(0xFFFEE2E2); // Red-50

  // Surface and background: Deep, rich blacks with subtle blue tint
  static const darkSurface = Color(0xFF0F172A); // Slate-900 (warmer than pure black)
  static const darkSurfaceDim = Color(0xFF1E293B); // Slate-800
  static const darkOnSurface = Color(0xFFF1F5F9); // Slate-100 (high contrast)
  static const darkOnSurfaceDim = Color(0xFFCBD5E1); // Slate-300
  static const darkBackground = Color(0xFF0A0E1A); // Near black with blue tint
  static const darkSurfaceVariant = Color(0xFF1E293B); // Slate-800
  static const darkSurfaceContainerHighest = Color(0xFF334155); // Slate-700
  static const darkOnSurfaceVariant = Color(0xFFCBD5E1); // Slate-300 (elevated contrast)

  // Outline and shadow
  static const darkOutline = Color(0xFF475569); // Slate-600
  static const darkOutlineVariant = Color(0xFF334155); // Slate-700
  static const darkShadow = Color(0xFF000000);
  static const darkInversePrimary = Color(0xFF6366F1);
  static const darkInverseSurface = Color(0xFFF1F5F9);
  static const darkOnInverseSurface = Color(0xFF0F172A);
  
  // Priority colors (adjusted for dark mode - more vibrant)
  static const priorityHigh = Color(0xFFFCA5A5); // Red-300
  static const priorityMedium = Color(0xFFFBBF24); // Amber-400
  static const priorityLow = Color(0xFF6EE7B7); // Emerald-300

  // Success, Warning, Info
  static const success = Color(0xFF6EE7B7);
  static const warning = Color(0xFFFBBF24);
  static const info = Color(0xFF60A5FA);
}

// =============================================================================
// TYPOGRAPHY SYSTEM
// =============================================================================

/// Premium font size constants with refined scale
class FontSizes {
  // Display (hero text)
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  
  // Headlines (section titles)
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  
  // Titles (card headers, important text)
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  
  // Labels (buttons, chips, tags)
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  
  // Body (main content)
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

/// Premium font family configuration
class AppFonts {
  // Primary font: Inter (clean, modern, highly readable)
  static String get primary => GoogleFonts.inter().fontFamily ?? 'Inter';
  
  // Display font: Inter with tighter tracking for large text
  static String get display => GoogleFonts.inter().fontFamily ?? 'Inter';
}

// =============================================================================
// THEMES
// =============================================================================

/// Premium light theme with refined aesthetics
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    secondaryContainer: LightModeColors.lightSecondaryContainer,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    tertiaryContainer: LightModeColors.lightTertiaryContainer,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
    surfaceContainerHighest: LightModeColors.lightSurfaceContainerHighest,
    onSurfaceVariant: LightModeColors.lightOnSurfaceVariant,
    outline: LightModeColors.lightOutline,
    outlineVariant: LightModeColors.lightOutlineVariant,
    shadow: LightModeColors.lightShadow,
    inversePrimary: LightModeColors.lightInversePrimary,
    inverseSurface: LightModeColors.lightInverseSurface,
    onInverseSurface: LightModeColors.lightOnInverseSurface,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: LightModeColors.lightBackground,
  
  // AppBar - transparent with no elevation
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: LightModeColors.lightOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: LightModeColors.lightOnSurface,
      letterSpacing: 0,
    ),
  ),
  
  // Card - soft shadows, premium radius
  cardTheme: CardThemeData(
    elevation: 0, // No elevation, use shadows instead
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
    color: LightModeColors.lightSurface,
    surfaceTintColor: Colors.transparent,
  ),
  
  // FloatingActionButton - premium styling
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: LightModeColors.lightPrimary,
    foregroundColor: LightModeColors.lightOnPrimary,
    elevation: 0,
    highlightElevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
  ),
  
  // ElevatedButton - premium rounded corners
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LightModeColors.lightPrimary,
      foregroundColor: LightModeColors.lightOnPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      textStyle: GoogleFonts.inter(
        fontSize: FontSizes.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // TextButton - refined styling
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: LightModeColors.lightPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      textStyle: GoogleFonts.inter(
        fontSize: FontSizes.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // OutlinedButton - premium borders
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: LightModeColors.lightPrimary,
      side: BorderSide(color: LightModeColors.lightPrimary, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      textStyle: GoogleFonts.inter(
        fontSize: FontSizes.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // InputDecoration - glassmorphism-ready
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LightModeColors.lightSurfaceVariant,
    border: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide(
        color: LightModeColors.lightPrimary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide(
        color: LightModeColors.lightError,
        width: 1.5,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide(
        color: LightModeColors.lightError,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  ),
  
  // Chip - premium rounded
  chipTheme: ChipThemeData(
    backgroundColor: LightModeColors.lightSurfaceVariant,
    deleteIconColor: LightModeColors.lightOnSurfaceVariant,
    disabledColor: LightModeColors.lightSurfaceVariant,
    selectedColor: LightModeColors.lightPrimaryContainer,
    secondarySelectedColor: LightModeColors.lightPrimaryContainer,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      color: LightModeColors.lightOnSurface,
    ),
    secondaryLabelStyle: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      color: LightModeColors.lightOnPrimaryContainer,
    ),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
  ),
  
  // Dialog - premium rounded
  dialogTheme: DialogThemeData(
    backgroundColor: LightModeColors.lightSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
    titleTextStyle: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
      color: LightModeColors.lightOnSurface,
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      color: LightModeColors.lightOnSurface,
    ),
  ),
  
  // BottomSheet - premium rounded
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: LightModeColors.lightSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
  ),
  
  // Divider - subtle
  dividerTheme: DividerThemeData(
    color: LightModeColors.lightOutlineVariant,
    thickness: 1,
    space: 1,
  ),
  
  textTheme: _buildTextTheme(Brightness.light),
);

/// Premium dark theme with refined aesthetics
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    secondaryContainer: DarkModeColors.darkSecondaryContainer,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    tertiaryContainer: DarkModeColors.darkTertiaryContainer,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
    surfaceContainerHighest: DarkModeColors.darkSurfaceContainerHighest,
    onSurfaceVariant: DarkModeColors.darkOnSurfaceVariant,
    outline: DarkModeColors.darkOutline,
    outlineVariant: DarkModeColors.darkOutlineVariant,
    shadow: DarkModeColors.darkShadow,
    inversePrimary: DarkModeColors.darkInversePrimary,
    inverseSurface: DarkModeColors.darkInverseSurface,
    onInverseSurface: DarkModeColors.darkOnInverseSurface,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkModeColors.darkBackground,
  
  // AppBar - transparent with no elevation
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: DarkModeColors.darkOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      color: DarkModeColors.darkOnSurface,
      letterSpacing: 0,
    ),
  ),
  
  // Card - soft shadows, premium radius
  cardTheme: CardThemeData(
    elevation: 0, // No elevation, use shadows instead
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
    color: DarkModeColors.darkSurface,
    surfaceTintColor: Colors.transparent,
  ),
  
  // FloatingActionButton - premium styling
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: DarkModeColors.darkPrimary,
    foregroundColor: DarkModeColors.darkOnPrimary,
    elevation: 0,
    highlightElevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
  ),
  
  // ElevatedButton - premium rounded corners
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DarkModeColors.darkPrimary,
      foregroundColor: DarkModeColors.darkOnPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      textStyle: GoogleFonts.inter(
        fontSize: FontSizes.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // TextButton - refined styling
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: DarkModeColors.darkPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      textStyle: GoogleFonts.inter(
        fontSize: FontSizes.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // OutlinedButton - premium borders
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DarkModeColors.darkPrimary,
      side: BorderSide(color: DarkModeColors.darkPrimary, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      textStyle: GoogleFonts.inter(
        fontSize: FontSizes.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  
  // InputDecoration - glassmorphism-ready
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: DarkModeColors.darkSurfaceVariant,
    border: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide(
        color: DarkModeColors.darkPrimary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide(
        color: DarkModeColors.darkError,
        width: 1.5,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.lgAll,
      borderSide: BorderSide(
        color: DarkModeColors.darkError,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  ),
  
  // Chip - premium rounded
  chipTheme: ChipThemeData(
    backgroundColor: DarkModeColors.darkSurfaceVariant,
    deleteIconColor: DarkModeColors.darkOnSurfaceVariant,
    disabledColor: DarkModeColors.darkSurfaceVariant,
    selectedColor: DarkModeColors.darkPrimaryContainer,
    secondarySelectedColor: DarkModeColors.darkPrimaryContainer,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      color: DarkModeColors.darkOnSurface,
    ),
    secondaryLabelStyle: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      color: DarkModeColors.darkOnPrimaryContainer,
    ),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
  ),
  
  // Dialog - premium rounded
  dialogTheme: DialogThemeData(
    backgroundColor: DarkModeColors.darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
    titleTextStyle: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
      color: DarkModeColors.darkOnSurface,
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      color: DarkModeColors.darkOnSurface,
    ),
  ),
  
  // BottomSheet - premium rounded
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: DarkModeColors.darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
  ),
  
  // Divider - subtle
  dividerTheme: DividerThemeData(
    color: DarkModeColors.darkOutlineVariant,
    thickness: 1,
    space: 1,
  ),
  
  textTheme: _buildTextTheme(Brightness.dark),
);

/// Build premium text theme with refined hierarchy and elevated contrast
TextTheme _buildTextTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final onSurface = isDark ? DarkModeColors.darkOnSurface : LightModeColors.lightOnSurface;
  final onSurfaceVariant = isDark ? DarkModeColors.darkOnSurfaceVariant : LightModeColors.lightOnSurfaceVariant;

  return TextTheme(
    // Display styles (hero text, large numbers)
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w300, // Lighter for large text
      letterSpacing: -1.0,
      height: 1.1,
      color: onSurface,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.75,
      height: 1.15,
      color: onSurface,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.5,
      height: 1.2,
      color: onSurface,
    ),
    
    // Headline styles (section titles, page headers)
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w700, // Bold for emphasis
      letterSpacing: -0.75,
      height: 1.2,
      color: onSurface,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.25,
      color: onSurface,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.3,
      color: onSurface,
    ),
    
    // Title styles (card headers, important labels)
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
      color: onSurface,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.35,
      color: onSurface,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      color: onSurface,
    ),
    
    // Label styles (buttons, chips, tags)
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w600, // Bolder for buttons
      letterSpacing: 0.1,
      height: 1.4,
      color: onSurface,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      color: onSurfaceVariant,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      color: onSurfaceVariant,
    ),
    
    // Body styles (main content, descriptions)
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.5, // Comfortable line height
      color: onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
      color: onSurface,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.5,
      color: onSurfaceVariant,
    ),
  );
}
