import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/services/brightness_provider.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required BrightnessProvider brightnessProvider}) : super(_initialThemeMode(brightnessProvider));

  static ThemeMode _initialThemeMode(BrightnessProvider brightnessProvider) {
    final brightness = brightnessProvider.currentBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}
