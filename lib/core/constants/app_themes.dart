import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppThemes {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final serifHeaderFont = GoogleFonts.outfit();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryNavy,
        secondary: AppColors.accentGold,
        surface: AppColors.cardLight,
        error: AppColors.crimsonRed,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.primaryNavy,
        indicatorColor: AppColors.accentGold.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold);
          }
          return GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentGold);
          }
          return const IconThemeData(color: Colors.white70);
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: serifHeaderFont.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: serifHeaderFont.copyWith(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
        headlineMedium: serifHeaderFont.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
        titleLarge: serifHeaderFont.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
        titleMedium: serifHeaderFont.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: GoogleFonts.inter(fontSize: 15, height: 1.6, color: AppColors.textDark),
        bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppColors.textMutedDark),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final serifHeaderFont = GoogleFonts.outfit();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentGold,
        secondary: AppColors.accentAmber,
        surface: AppColors.secondaryNavy,
        error: AppColors.crimsonRed,
      ),
      scaffoldBackgroundColor: AppColors.primaryNavy,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.secondaryNavy,
        indicatorColor: AppColors.accentGold.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold);
          }
          return GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentGold);
          }
          return const IconThemeData(color: Colors.white70);
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: serifHeaderFont.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: serifHeaderFont.copyWith(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textLight),
        headlineMedium: serifHeaderFont.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textLight),
        titleLarge: serifHeaderFont.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textLight),
        titleMedium: serifHeaderFont.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textLight),
        bodyLarge: GoogleFonts.inter(fontSize: 15, height: 1.6, color: AppColors.textLight),
        bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppColors.textMutedLight),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.secondaryNavy,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
