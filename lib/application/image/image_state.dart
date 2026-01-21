import '../../domain/entities/extracted_colors.dart';

class ImageState {
  const ImageState({this.isLoading = true, this.imageUrl, this.extractedColors, this.errorMessage});

  final bool isLoading;
  final String? imageUrl;
  final ExtractedColors? extractedColors;
  final String? errorMessage;

  ImageState copyWith({bool? isLoading, String? imageUrl, ExtractedColors? extractedColors, String? errorMessage}) {
    return ImageState(
      isLoading: isLoading ?? this.isLoading,
      imageUrl: imageUrl ?? this.imageUrl,
      extractedColors: extractedColors ?? this.extractedColors,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
