import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Deep Petrol Teal
  static const Color primaryTeal = Color(0xFF016574);
  static const Color primaryTealDark = Color(0xFF004652);
  static const Color primaryTealLight = Color(0xFFE6F2F4);

  // Gold Accents
  static const Color goldAccent = Color(0xFFC89336);
  static const Color goldLight = Color(0xFFE8C882);

  // Backgrounds
  static const Color creamBackground = Color(0xFFF9F6EE);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Input Fields
  static const Color inputBorder = Color(0xFFCFE0E3);
  static const Color inputHint = Color(0xFF8E9BA4);
  static const Color textDark = Color(0xFF003843);
  static const Color textMuted = Color(0xFF6B7B83);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primaryTeal,
      scaffoldBackgroundColor: AppColors.creamBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTeal,
        primary: AppColors.primaryTeal,
        secondary: AppColors.goldAccent,
        surface: AppColors.cardWhite,
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        titleLarge: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTeal,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryTeal,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}
