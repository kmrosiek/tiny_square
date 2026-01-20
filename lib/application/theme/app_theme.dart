import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => fromColors(AppColors.light, Brightness.light);
  static ThemeData get dark => fromColors(AppColors.dark, Brightness.dark);

  static ThemeData fromColors(AppColors colors, Brightness brightness) {
    final colorScheme = brightness == Brightness.light
        ? ColorScheme.light(primary: colors.primary, secondary: colors.primary, error: colors.error)
        : ColorScheme.dark(primary: colors.primary, secondary: colors.primary, error: colors.error);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: colors.onPrimary)),
    );
  }
}
