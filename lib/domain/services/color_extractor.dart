import 'package:flutter/material.dart';

abstract class ColorExtractor {
  Future<Color?> extractDominantColor(ImageProvider imageProvider);
}
