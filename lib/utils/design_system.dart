import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Enhanced Material 3 design system with modern styling and typography
class UssdDesignSystem {
  // Modern Color Schemes
  static ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2563EB), // Modern blue
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF2563EB),
    secondary: const Color(0xFF10B981), // Success green
    tertiary: const Color(0xFFF59E0B),  // Warning amber
    error: const Color(0xFFEF4444),     // Error red
    surface: const Color(0xFFFAFAFA),
    surfaceVariant: const Color(0xFFF5F5F5),
    surfaceContainer: const Color(0xFFE8E8E8),
    surfaceContainerHighest: const Color(0xFFE0E0E0),
  );
  
  static ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3B82F6),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF60A5FA),
    secondary: const Color(0xFF34D399),
    tertiary: const Color(0xFFFBBF24),
    error: const Color(0xFFF87171),
    surface: const Color(0xFF111827),
    surfaceVariant: const Color(0xFF1F2937),
    surfaceContainer: const Color(0xFF374151),
    surfaceContainerHighest: const Color(0xFF4B5563),
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
        height: 1.3,
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

  // Design Tokens
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius borderRadiusXLarge = BorderRadius.all(Radius.circular(24));

  // Spacing tokens
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Animation curves
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;

  // Elevation levels
  static const double elevationLevel1 = 1.0;
  static const double elevationLevel2 = 3.0;
  static const double elevationLevel3 = 6.0;
  static const double elevationLevel4 = 8.0;
  static const double elevationLevel5 = 12.0;

  // Enhanced theme data
  static ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: lightColorScheme,
      textTheme: getTextTheme(lightColorScheme),
      useMaterial3: true,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: elevationLevel2,
        margin: EdgeInsets.zero,
        color: lightColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(color: lightColorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(color: lightColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevationLevel2,
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: lightColorScheme.outline),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarTheme(
        backgroundColor: lightColorScheme.surface,
        selectedItemColor: lightColorScheme.primary,
        unselectedItemColor: lightColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: elevationLevel3,
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: darkColorScheme,
      textTheme: getTextTheme(darkColorScheme),
      useMaterial3: true,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkColorScheme.onSurface,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: elevationLevel2,
        margin: EdgeInsets.zero,
        color: darkColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(color: darkColorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide(color: darkColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevationLevel2,
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: darkColorScheme.outline),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarTheme(
        backgroundColor: darkColorScheme.surface,
        selectedItemColor: darkColorScheme.primary,
        unselectedItemColor: darkColorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: elevationLevel3,
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
      colors: [
        colorScheme.primary,
        colorScheme.primary.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}