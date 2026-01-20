import 'package:flutter/material.dart';

class ExtractedColors {
  const ExtractedColors({this.lightBackground, this.darkBackground, this.lightTextColor, this.darkTextColor});

  final Color? lightBackground;
  final Color? darkBackground;
  final Color? lightTextColor;
  final Color? darkTextColor;

  Color? backgroundForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  Color? textColorForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextColor : lightTextColor;
  }
}
