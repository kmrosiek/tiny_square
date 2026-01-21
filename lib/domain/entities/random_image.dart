import 'extracted_colors.dart';

class RandomImage {
  const RandomImage({required this.url, this.extractedColors});

  final String url;
  final ExtractedColors? extractedColors;
}
