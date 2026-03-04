import 'package:flutter/material.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryEmerald,
        brightness: Brightness.light,
        primary: AppColors.primaryEmerald,
        secondary: AppColors.secondaryEmerald,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryEmerald,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryEmerald,
        brightness: Brightness.dark,
        primary: AppColors.primaryEmerald,
        secondary: AppColors.secondaryEmerald,
        background: const Color(0xFF0F1923),
        surface: const Color(0xFF1A2F4A),
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1923),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryEmerald,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2F4A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
    );
  }

  // Helper methods for theme-aware colors
  static LinearGradient getBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const LinearGradient(
        colors: [Color(0xFF0F1923), Color(0xFF1A2F4A), Color(0xFF0F1923)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return AppColors.backgroundGradient;
  }

  static Color getScaffoldBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0F1923) : AppColors.background;
  }

  static Color getSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A2F4A) : Colors.white;
  }

  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF225064) : AppColors.surface;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : AppColors.textPrimary;
  }

  static Color getModalBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A2F4A) : AppColors.mintLight;
  }

  static Color getAccentMintColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF35D6A6).withOpacity(0.2) : AppColors.mint;
  }

  // TextStyle helpers for theme-aware text
  static TextStyle getTitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      color: isDark ? Colors.white : AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    );
  }

  static TextStyle getHeading2Style(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      color: isDark ? Colors.white : AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle getBodyStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      color: isDark ? Colors.white : AppColors.textPrimary,
      fontSize: 14,
    );
  }

  static TextStyle getSubtitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      color: isDark ? Colors.white70 : AppColors.textSecondary,
      fontSize: 12,
    );
  }
}
