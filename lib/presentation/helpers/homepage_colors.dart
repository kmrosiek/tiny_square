import 'package:flutter/material.dart';
import 'package:tiny_square/domain/entities/extracted_colors.dart';

class HomepageColors {
  const HomepageColors._({
    required this.background,
    required this.tintedPrimary,
    required this.onTintedPrimary,
    required this.themeToggle,
  });

  factory HomepageColors.fromContext(BuildContext context, ExtractedColors? extractedColors) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final background = extractedColors?.backgroundForBrightness(brightness) ?? theme.scaffoldBackgroundColor;
    final imageColor = extractedColors?.textColorForBrightness(brightness);
    final primary = theme.colorScheme.primary;

    final tintedPrimary = Color.lerp(primary, imageColor, imageColor != null ? 0.4 : 0.0)!;

    final onTintedPrimary = ThemeData.estimateBrightnessForColor(tintedPrimary) == Brightness.dark
        ? background
        : Color.lerp(background, Colors.black, 0.7)!;

    final themeToggle = brightness == Brightness.dark ? tintedPrimary : onTintedPrimary;

    return HomepageColors._(
      background: background,
      tintedPrimary: tintedPrimary,
      onTintedPrimary: onTintedPrimary,
      themeToggle: themeToggle,
    );
  }

  final Color background;
  final Color tintedPrimary;
  final Color onTintedPrimary;
  final Color themeToggle;
}
