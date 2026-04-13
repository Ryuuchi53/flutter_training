import 'package:flutter/material.dart';

/// Purple palette — soft lavender to deep violet for a cohesive theme.
class AppColors {
  AppColors._();

  static const Color lavender = Color(0xFFF3E5F5);
  static const Color lightPurple = Color(0xFFCE93D8);
  static const Color purple = Color(0xFF9C27B0);
  static const Color deepPurple = Color(0xFF6A1B9A);
  static const Color darkPurple = Color(0xFF4A148C);
  static const Color violet = Color(0xFF7B1FA2);
  static const Color accentPurple = Color(0xFFE040FB);
  static const Color card = Color(0xFFFFFFFF);
}

ThemeData buildAppTheme() {
  const primary = AppColors.deepPurple;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: AppColors.deepPurple,
      onPrimary: Colors.white,
      secondary: AppColors.accentPurple,
      onSecondary: Colors.white,
      tertiary: AppColors.lightPurple,
      surface: AppColors.card,
      onSurface: AppColors.darkPurple,
      surfaceContainerHighest: AppColors.lavender,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.deepPurple,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lavender.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.lightPurple.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.deepPurple;
        }
        return null;
      }),
      side: const BorderSide(color: AppColors.purple, width: 1.5),
    ),
  );
}