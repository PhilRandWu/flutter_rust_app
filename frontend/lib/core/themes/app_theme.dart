import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      secondaryHeaderColor: AppColors.secondary,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      secondaryHeaderColor: AppColors.secondary,
    );
  }
}
