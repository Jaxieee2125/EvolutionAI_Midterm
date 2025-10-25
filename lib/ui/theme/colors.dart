import 'package:flutter/material.dart';

class AppColors {
  // Light theme
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFFFFD23F);
  static const Color accent = Color(0xFF4ECDC4);

  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF1A1A1A);
  static const Color muted = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Dark theme
  static const Color darkPrimary = Color(0xFFFF8C5A);
  static const Color darkSecondary = Color(0xFFFFD966);
  static const Color darkAccent = Color(0xFF5ED9CF);

  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkForeground = Color(0xFFFFFFFF);
  static const Color darkMuted = Color(0xFF262626);
  static const Color darkTextMuted = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF333333);

  // Common
  static const double radius = 16;
}
class AppGradients {
  static const LinearGradient header = LinearGradient(
    colors: [AppColors.primary, AppColors.accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}