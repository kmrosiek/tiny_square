import 'dart:typed_data';
import 'extracted_colors.dart';

class RandomImage {
  const RandomImage({required this.bytes, this.extractedColors});

  final Uint8List bytes;
  final ExtractedColors? extractedColors;
}
