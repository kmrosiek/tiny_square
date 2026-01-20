import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator_master/palette_generator_master.dart';
import '../../domain/repositories/image_repository.dart';
import 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  final ImageRepository repository;

  ImageCubit({required this.repository}) : super(const ImageInitial());

  Future<void> loadImage() async {
    emit(const ImageLoading());

    try {
      final image = await repository.getRandomImage();
      emit(ImageLoaded(imageUrl: image.url, backgroundColor: Colors.grey.shade800, textColor: Colors.white));
    } catch (e) {
      emit(ImageError(message: e.toString()));
    }
  }

  Future<void> updateColorsFromImage(ImageProvider imageProvider) async {
    final currentState = state;
    if (currentState is! ImageLoaded) return;

    try {
      final paletteGenerator = await PaletteGeneratorMaster.fromImageProvider(
        imageProvider,
        size: const Size(100, 100),
        maximumColorCount: 16,
      );

      final backgroundColor =
          paletteGenerator.dominantColor?.color ?? paletteGenerator.vibrantColor?.color ?? Colors.grey.shade800;

      final textColor = _getContrastingTextColor(backgroundColor);

      emit(ImageLoaded(imageUrl: currentState.imageUrl, backgroundColor: backgroundColor, textColor: textColor));
    } catch (_) {}
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
