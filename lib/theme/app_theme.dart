import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Stitch Exact Palette
  static const Color background = Color(0xFFFCF9F3);
  static const Color surface = Color(0xFFFCF9F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3ED);
  static const Color surfaceContainer = Color(0xFFF0EEE8);
  static const Color surfaceContainerHigh = Color(0xFFEBE8E2);
  static const Color surfaceContainerHighest = Color(0xFFE5E2DC);

  static const Color onSurface = Color(0xFF1C1C18);
  static const Color onSurfaceVariant = Color(0xFF45464D);
  static const Color outline = Color(0xFF76777D);
  static const Color outlineVariant = Color(0xFFC6C6CD);

  static const Color primary = Color(0xFF131B2E);
  static const Color primaryFixed = Color(0xFFDAE2FD);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF006C4A);
  static const Color secondaryContainer = Color(0xFF82F5C1);
  static const Color secondaryContainerLight = Color(0xFFECFDF5);
  static const Color onSecondaryContainer = Color(0xFF00714E);
  static const Color secondaryBorder = Color(0xFFA7F3D0);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color alertBg = Color(0xFFFEF2F2);
  static const Color alertBorder = Color(0xFFFCA5A5);
  static const Color alertText = Color(0xFFDC2626);
  static const Color alertDark = Color(0xFF7F1D1D);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.6,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.4,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.2,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
