import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/logger/logger.dart';
import '../../domain/repositories/image_repository.dart';
import 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  ImageCubit({required this.repository, required this.logger}) : super(const ImageState());

  static const _logTag = '[ImageCubit]';

  final ImageRepository repository;
  final Logger logger;

  Future<void> initialize() async {
    logger.debug('$_logTag: Initializing');
    await repository.initialize();
    logger.info('$_logTag: initialized');
    await fetchNextImage();
  }

  Future<void> fetchNextImage() async {
    logger.debug('$_logTag: Fetching next image');
    emit(state.copyWith(isLoading: true));

    final result = await repository.getNextImage();

    result.fold(
      (failure) {
        logger.warning('$_logTag: Failed to fetch image: ${failure.message}');
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (image) {
        logger.info('$_logTag: Successfully fetched image');
        emit(ImageState(isLoading: false, imageBytes: image.bytes, extractedColors: image.extractedColors));
      },
    );
  }
}
