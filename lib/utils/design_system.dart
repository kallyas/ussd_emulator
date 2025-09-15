import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Enhanced Material 3 design system with modern styling and typography
class UssdDesignSystem {
  static ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: lightColorScheme,
      textTheme: getTextTheme(lightColorScheme),
      useMaterial3: true,
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: darkColorScheme,
      textTheme: getTextTheme(darkColorScheme),
      useMaterial3: true,
    );
  }

  // Spacing tokens
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius tokens
  static const double radiusS = 8.0;
  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(8),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(16),
  );
  static const BorderRadius borderRadiusXLarge = BorderRadius.all(
    Radius.circular(24),
  );

  // Elevation tokens
  static const double elevationLevel1 = 1.0;
  static const double elevationLevel2 = 3.0;
  static const double elevationLevel3 = 6.0;
  static const double elevationLevel4 = 8.0;
  static const double elevationLevel5 = 12.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Animation curves
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveDefault = Curves.ease;
  static const Duration animationMedium = Duration(milliseconds: 300);
  // Modern, visually appealing color scheme
  static ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF0057B8), // Deep blue
    onPrimary: Colors.white,
    secondary: const Color(0xFF00B894), // Teal
    onSecondary: Colors.white,
    error: const Color(0xFFD7263D), // Vivid red
    onError: Colors.white,
    background: const Color(0xFFF6F8FA),
    onBackground: const Color(0xFF22223B),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF22223B),
    surfaceVariant: const Color(0xFFE0E7EF),
    onSurfaceVariant: const Color(0xFF4A4E69),
    outline: const Color(0xFFBFC9D1),
    primaryContainer: const Color(0xFFB3D0FF),
    onPrimaryContainer: const Color(0xFF003366),
    secondaryContainer: const Color(0xFFB2F7EF),
    onSecondaryContainer: const Color(0xFF00332E),
    errorContainer: const Color(0xFFFFD6D6),
    onErrorContainer: const Color(0xFF7A0019),
    surfaceContainer: const Color(0xFFF0F4F8),
    surfaceContainerHighest: const Color(0xFFE0E7EF),
  );

  static ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF64A8FF), // Lighter blue
    onPrimary: const Color(0xFF001F3F),
    secondary: const Color(0xFF00E6C3),
    onSecondary: const Color(0xFF00332E),
    error: const Color(0xFFFF5C77),
    onError: const Color(0xFF7A0019),
    background: const Color(0xFF181A1B),
    onBackground: const Color(0xFFF6F8FA),
    surface: const Color(0xFF23272E),
    onSurface: const Color(0xFFF6F8FA),
    surfaceVariant: const Color(0xFF2C3140),
    onSurfaceVariant: const Color(0xFFBFC9D1),
    outline: const Color(0xFF4A4E69),
    primaryContainer: const Color(0xFF003366),
    onPrimaryContainer: const Color(0xFFB3D0FF),
    secondaryContainer: const Color(0xFF00332E),
    onSecondaryContainer: const Color(0xFFB2F7EF),
    errorContainer: const Color(0xFF7A0019),
    onErrorContainer: const Color(0xFFFFD6D6),
    surfaceContainer: const Color(0xFF23272E),
    surfaceContainerHighest: const Color(0xFF2C3140),
  );

  // Typography Scale using Inter font
  static TextTheme getTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.25,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }

  // Utility methods for shadows and gradients
  static List<BoxShadow> getShadow(double elevation, {Color? color}) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withOpacity(0.08),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
      BoxShadow(
        color: (color ?? Colors.black).withOpacity(0.04),
        blurRadius: elevation,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }

  static LinearGradient getPrimaryGradient(ColorScheme colorScheme) {
    return LinearGradient(
      colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
