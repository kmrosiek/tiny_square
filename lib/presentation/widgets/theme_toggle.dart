import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiny_square/application/theme/theme_cubit.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, required this.iconColor});
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.textScalerOf(context).scale(24);
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final icon = switch (themeMode) {
          ThemeMode.system => Icons.brightness_auto,
          ThemeMode.light => Icons.light_mode,
          ThemeMode.dark => Icons.dark_mode,
        };
        final tooltip = switch (themeMode) {
          ThemeMode.system => 'System theme',
          ThemeMode.light => 'Light theme',
          ThemeMode.dark => 'Dark theme',
        };
        return IconButton(
          icon: Icon(icon, color: iconColor, size: iconSize),
          tooltip: 'Toggle theme. Current: $tooltip',
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        );
      },
    );
  }
}
