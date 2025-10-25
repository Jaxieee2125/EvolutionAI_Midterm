import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static final textTheme = TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMuted),
    bodyMedium: TextStyle(fontSize: 16, color: AppColors.textMuted),
  );
  static final textThemeDark = textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white);
}
