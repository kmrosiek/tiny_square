import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/services/color_extractor.dart';
import 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  ImageCubit({required this.repository, required this.colorExtractor}) : super(const ImageState());

  final ImageRepository repository;
  final ColorExtractor colorExtractor;

  Future<void> fetchRandomImage() async {
    emit(state.copyWith(isLoading: true));

    final result = await repository.getRandomImage();

    result.fold((failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)), (image) async {
      emit(state.copyWith(imageBytes: image.bytes));
      final extractedColors = await colorExtractor.extractColors(image.bytes);
      emit(ImageState(imageBytes: image.bytes, extractedColors: extractedColors));
    });
  }
}
