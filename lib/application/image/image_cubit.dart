import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator_master/palette_generator_master.dart';
import '../../domain/repositories/image_repository.dart';
import 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  final ImageRepository repository;

  ImageCubit({required this.repository}) : super(const ImageState());

  Future<void> loadImage() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final image = await repository.getRandomImage();
      emit(state.copyWith(
        isLoading: false,
        imageUrl: image.url,
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateColorsFromImage(ImageProvider imageProvider) async {
    if (state.imageUrl == null || state.isLoading) return;

    try {
      final paletteGenerator = await PaletteGeneratorMaster.fromImageProvider(
        imageProvider,
        size: const Size(100, 100),
        maximumColorCount: 16,
      );

      final backgroundColor = paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          Colors.grey.shade800;

      final textColor = _getContrastingTextColor(backgroundColor);

      emit(state.copyWith(
        backgroundColor: backgroundColor,
        textColor: textColor,
      ));
    } catch (_) {}
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
