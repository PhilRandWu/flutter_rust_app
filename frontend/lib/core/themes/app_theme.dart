import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/typography.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  final String name;
  final Brightness brightness;
  final AppThemeColors colors;
  final AppThemeTypography typographies;

  const AppTheme({
    required this.name,
    required this.brightness,
    required this.colors,
    this.typographies = const AppThemeTypography(),
  });

  ColorScheme get baseColorScheme => brightness == Brightness.light ? const ColorScheme.light() : const ColorScheme.dark();

  ThemeData get themeData => ThemeData(
      fontFamily: 'Montserrat',
      useMaterial3: false,
      platform: TargetPlatform.iOS,
      extensions: [this],
      brightness: brightness,
      primarySwatch: colors.primarySwatch,
      primaryColor: colors.primary,
      unselectedWidgetColor: colors.hint,
      disabledColor: colors.disabled,
      scaffoldBackgroundColor: colors.background,
      hintColor: colors.hint,
      dividerColor: colors.border,
      colorScheme: baseColorScheme.copyWith(
        primary: colors.primary,
        onPrimary: colors.textOnPrimary,
        secondary: colors.secondary,
        onSecondary: colors.textOnPrimary,
        error: colors.error,
        shadow: colors.border,
      ),
  );

  @override
  ThemeExtension<AppTheme> copyWith({
    String? name,
    Brightness? brightness,
    AppThemeColors? colors,
    AppThemeTypography? typographies,
  }) {
    return AppTheme(
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
      colors: colors ?? this.colors,
      typographies: typographies ?? this.typographies,
    );
  }

  @override
  ThemeExtension<AppTheme> lerp(
    covariant ThemeExtension<AppTheme>? other,
    double t,
  ) {
    if (other is! AppTheme) return this;
    return AppTheme(
      name: name,
      brightness: brightness,
      colors: colors,
      typographies: typographies.lerp(other.typographies, t),
    );
  }
}
