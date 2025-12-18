import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/typography.dart';
import 'package:frontend/core/themes/app_theme.dart';

extension BuildContextExtension on BuildContext {
  AppTheme get appTheme => Theme.of(this).extension<AppTheme>()!;

  AppThemeColors get colors => appTheme.colors;

  AppThemeTypography get typographies => appTheme.typographies;
}
