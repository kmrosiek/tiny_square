import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/image_repository.dart';
import 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  ImageCubit({required this.repository}) : super(const ImageState());

  final ImageRepository repository;

  Future<void> fetchNextImage() async {
    emit(state.copyWith(isLoading: true));

    final result = await repository.getRandomImage();

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (image) => emit(ImageState(imageBytes: image.bytes, extractedColors: image.extractedColors)),
    );
  }
}
