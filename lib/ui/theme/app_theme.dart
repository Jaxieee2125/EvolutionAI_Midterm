import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  final ThemeData light;
  final ThemeData dark;
  AppTheme._(this.light, this.dark);

  static AppTheme build() {
    final light = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: AppColors.foreground,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
        background: AppColors.background,
        onBackground: AppColors.foreground,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTextStyles.textTheme,
      cardColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.foreground,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );

    final dark = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkForeground,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkForeground,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkForeground,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTextStyles.textThemeDark,
      cardColor: AppColors.darkMuted,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkForeground,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );

    return AppTheme._(light, dark);
  }
}
