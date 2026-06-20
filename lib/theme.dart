import 'package:flutter/material.dart';

/// Central place for colors, spacing and text styles used across Ebro.
/// Keeping this in one file means the whole app's look can be tuned
/// from a single spot instead of hunting through every screen.
class AppColors {
  static const bgBase = Color(0xFF0A0A14);
  static const bgSurface = Color(0xFF111120);
  static const bgCard = Color(0xFF16162A);
  static const bgHover = Color(0xFF1E1E38);
  static const bgInput = Color(0xFF0D0D1E);

  static const accent = Color(0xFF6C63FF);
  static const accentLight = Color(0xFF8B84FF);
  static const accentDim = Color(0x266C63FF);

  static const coral = Color(0xFFFF6B6B);
  static const coralDim = Color(0x1FFF6B6B);

  static const green = Color(0xFF4ECDC4);
  static const greenDim = Color(0x1F4ECDC4);

  static const amber = Color(0xFFFFD166);

  static const textPrimary = Color(0xFFF0F0F8);
  static const textSecondary = Color(0xFF8888AA);
  static const textMuted = Color(0xFF55556A);

  static const border = Color(0x0FFFFFFF);
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
}

ThemeData buildEbroTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgBase,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.coral,
      surface: AppColors.bgCard,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgSurface,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
  );
}
