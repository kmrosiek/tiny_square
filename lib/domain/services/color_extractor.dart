import 'package:flutter/material.dart';
import '../entities/extracted_colors.dart';

abstract class ColorExtractor {
  Future<ExtractedColors> extractColors(ImageProvider imageProvider);
}
