import 'dart:typed_data';
import '../../domain/entities/extracted_colors.dart';

class ImageState {
  const ImageState({
    this.isLoading = false,
    this.imageBytes,
    this.extractedColors,
    this.errorMessage,
  });

  final bool isLoading;
  final Uint8List? imageBytes;
  final ExtractedColors? extractedColors;
  final String? errorMessage;

  ImageState copyWith({
    bool? isLoading,
    Uint8List? imageBytes,
    ExtractedColors? extractedColors,
    String? errorMessage,
  }) {
    return ImageState(
      isLoading: isLoading ?? this.isLoading,
      imageBytes: imageBytes ?? this.imageBytes,
      extractedColors: extractedColors ?? this.extractedColors,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
