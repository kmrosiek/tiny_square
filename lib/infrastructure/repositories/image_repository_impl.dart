import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failure.dart';
import '../../core/logger/logger.dart';
import '../../domain/entities/random_image.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/services/color_extractor.dart';
import '../constants/prefetch_constants.dart';
import '../datasources/image_remote_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  ImageRepositoryImpl({required this.dataSource, required this.colorExtractor, required this.logger}) {
    _initializeQueue();
  }

  static const _logTag = '[ImageRepositoryImpl]';

  final ImageRemoteDataSource dataSource;
  final ColorExtractor colorExtractor;
  final Logger logger;
  final Queue<RandomImage> _imageQueue = Queue();
  final StreamController<RandomImage> _imageStreamController = StreamController<RandomImage>.broadcast();
  bool _isInitializing = false;
  bool _isDisposed = false;
  Failure? _lastFillQueueFailure;

  Future<RandomImage> _internalGetNextImage() async {
    // If queue has images, return the first one immediately
    if (_imageQueue.isNotEmpty) {
      return _imageQueue.removeFirst();
    }
    // Otherwise, wait for next image from stream
    return _imageStreamController.stream.first;
  }

  @override
  Future<void> initialize() async {
    logger.debug('$_logTag: Initializing ImageRepositoryImpl');
    await _initializeQueue();
  }

  Future<void> _initializeQueue() async {
    if (_isInitializing) {
      logger.debug('$_logTag: Queue initialization already in progress');
      return;
    }
    _isInitializing = true;
    logger.debug('$_logTag: Initializing image queue');
    try {
      await _fillQueue();
      logger.info('$_logTag: Image queue initialized with ${_imageQueue.length} images');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _fillQueue() async {
    logger.debug(
      '$_logTag: Filling image queue. Current size: ${_imageQueue.length}, Target: ${PrefetchConstants.urlBufferTarget}',
    );
    // Clear previous failure when starting a new fill attempt
    _lastFillQueueFailure = null;

    while (_imageQueue.length < PrefetchConstants.urlBufferTarget) {
      try {
        final url = await dataSource.getImageUrl();
        final result = await dataSource.downloadImage(url);
        final extractedColors = await colorExtractor.extractColors(result.bytes);
        final randomImage = RandomImage(bytes: result.bytes, extractedColors: extractedColors);

        if (_imageStreamController.hasListener && _imageQueue.isEmpty) {
          logger.debug('$_logTag: Adding image to stream (listener waiting and no images in queue)');
          _imageStreamController.add(randomImage);
        } else {
          logger.debug('$_logTag: Adding image to queue (no listener waiting or images in queue)');
          _imageQueue.add(randomImage);
        }
        logger.debug('$_logTag: Added image to queue. Queue size: ${_imageQueue.length}');
      } on ImageNotFoundException catch (e) {
        logger.warning('$_logTag: Image not found at ${e.url}, skipping to next...', e);
        continue; // Continue loop to try another image
      } catch (e, stackTrace) {
        logger.warning('$_logTag: Failed to get image for queue, stopping refill', e, stackTrace);
        final failure = ServerFailure('Failed to fetch images: $e');
        _lastFillQueueFailure = failure;
        if (_imageStreamController.hasListener) {
          _imageStreamController.addError(failure, stackTrace);
        }
        break;
      }
    }
    logger.info('$_logTag: Finished filling queue. Final size: ${_imageQueue.length}');
  }

  @override
  Future<Either<Failure, RandomImage>> getNextImage() async {
    if (_isDisposed) {
      logger.warning('$_logTag: Attempted to get next image after disposal');
      return const Left(ServerFailure('Repository has been disposed'));
    }
    logger.debug('$_logTag: Getting next image. Queue size: ${_imageQueue.length}');

    // Ensure queue is initialized
    if (_imageQueue.isEmpty && !_isInitializing) {
      logger.info('$_logTag: Queue is empty, initializing...');
      await _initializeQueue();

      // Check again after initialization - if it failed and queue is still empty, return error
      if (_imageQueue.isEmpty && _lastFillQueueFailure != null) {
        logger.warning('$_logTag: Queue initialization failed, returning error');
        return Left(_lastFillQueueFailure!);
      }
    }

    try {
      // Await next image (from queue if available, otherwise from stream)
      final image = await _internalGetNextImage();
      logger.info('$_logTag: Successfully retrieved pre-processed image. Remaining queue size: ${_imageQueue.length}');

      // Refill queue in background if below target (after image is consumed)
      if (_imageQueue.length < PrefetchConstants.urlBufferTarget && !_isInitializing) {
        logger.debug('$_logTag: Queue below target, refilling in background');
        unawaited(_fillQueue());
      }

      return Right(image);
    } on Failure catch (e) {
      return Left(e);
    } on SocketException catch (e, stackTrace) {
      logger.error('$_logTag: Network error while getting next image', e, stackTrace);
      return const Left(NetworkFailure('No internet connection'));
    } catch (e, stackTrace) {
      logger.error('$_logTag: Error getting next image', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    logger.debug('$_logTag: Disposing ImageRepositoryImpl');
    _isDisposed = true;
    _imageStreamController.close();
    _imageQueue.clear();
    colorExtractor.dispose();
  }
}
