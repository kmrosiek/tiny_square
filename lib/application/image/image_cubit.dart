import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/services/color_extractor.dart';
import 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  ImageCubit({required this.repository, required this.colorExtractor}) : super(const ImageState());

  final ImageRepository repository;
  final ColorExtractor colorExtractor;

  Future<void> loadImage() async {
    emit(state.copyWith(isLoading: true));

    try {
      final image = await repository.getRandomImage();
      emit(
        state.copyWith(
          isLoading: false,
          imageUrl: image.url,
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateColorsFromImage(ImageProvider imageProvider) async {
    if (state.imageUrl == null || state.isLoading) {
      return;
    }

    try {
      final dominantColor = await colorExtractor.extractDominantColor(imageProvider);
      final backgroundColor = dominantColor ?? Colors.grey.shade800;
      final textColor = _getContrastingTextColor(backgroundColor);

      emit(state.copyWith(backgroundColor: backgroundColor, textColor: textColor));
    } catch (_) {}
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
