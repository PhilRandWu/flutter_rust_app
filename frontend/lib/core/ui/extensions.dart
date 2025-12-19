import 'package:flutter/material.dart';
import 'package:frontend/core/ui/styles/styles.dart';
import 'package:frontend/core/ui/typography/typography.dart';

import 'app_theme.dart';
import 'colors/app_colors.dart';

extension BuildContextExtension on BuildContext {
  AppTheme get appTheme => Theme.of(this).extension<AppTheme>()!;

  AppThemeColors get colors => appTheme.colors;

  AppThemeStyles get styles => appTheme.styles;

  AppThemeTypography get typographies => appTheme.typographies;
}
