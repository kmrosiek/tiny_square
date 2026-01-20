import 'dart:typed_data';
import '../entities/extracted_colors.dart';

abstract class ColorExtractor {
  Future<ExtractedColors> extractColors(Uint8List imageBytes);
}
