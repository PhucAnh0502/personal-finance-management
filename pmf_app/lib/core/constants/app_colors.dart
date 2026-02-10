import 'package:flutter/material.dart';

class AppColors {
  // Primary color palette
  static const Color primaryEmerald = Color(0xFF35D6A6);
  static const Color secondaryEmerald = Color(0xFFDFFAF0);
  static const Color navyDark = Color(0xFF1A2B3A);
  static const Color accentGold = Color(0xFF9BE7C4);
  static const Color mint = Color(0xFFBFF5DF);
  static const Color mintLight = Color(0xFFF2FFF9);
  static const Color emeraldDeep = Color(0xFF169E7A);

  //Financial status colors
  static const Color income = Color(0xFF1DBE76);
  static const Color expense = Color(0xFFFF5C5C);
  static const Color debt = Color(0xFFFF9F43);

  // Background and surface colors
  static const Color background = Color(0xFFF5FFF9);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFFF5C5C);

  // Text colors
  static const Color textPrimary = Color(0xFF1E2A32);
  static const Color textSecondary = Color(0xFF5F6E7A);
  static const Color textOnNavy = Colors.white;

  //Gradient colors
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF35D6A6), Color(0xFF7CF0C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF22CFA0), Color(0xFF7CF0C7), Color(0xFFBFF5DF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [mintLight, secondaryEmerald, mint, Color(0xFF9FEBCB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1B2631)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}