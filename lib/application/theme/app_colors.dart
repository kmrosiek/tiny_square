import 'package:flutter/material.dart';

abstract class AppColors {
  Color get primary;
  Color get onPrimary;
  Color get error;

  static const AppColors light = _LightAppColors();
  static const AppColors dark = _DarkAppColors();
}

class _LightAppColors implements AppColors {
  const _LightAppColors();

  @override
  Color get primary => const Color(0xFFFFFDD0);

  @override
  Color get onPrimary => Colors.black;

  @override
  Color get error => const Color(0xFFF6002D);
}

class _DarkAppColors implements AppColors {
  const _DarkAppColors();

  @override
  Color get primary => const Color(0xFFE9810E);

  @override
  Color get onPrimary => Colors.white;

  @override
  Color get error => const Color(0xFFB00020);
}
