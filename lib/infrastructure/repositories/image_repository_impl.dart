import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dartz/dartz.dart';

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
  final Queue<String> _urlQueue = Queue();
  final StreamController<String> _urlStreamController = StreamController<String>.broadcast();
  bool _isInitializing = false;
  bool _isDisposed = false;

  Future<String> _getNextUrl() async {
    // If queue has URLs, return the first one immediately
    if (_urlQueue.isNotEmpty) {
      return _urlQueue.removeFirst();
    }
    // Otherwise, wait for next URL from stream
    return _urlStreamController.stream.first;
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
    logger.debug('$_logTag: Initializing URL queue');
    _isInitializing = true;
    await _fillQueue();
    _isInitializing = false;
    logger.info('$_logTag: URL queue initialized with ${_urlQueue.length} URLs');
  }

  Future<void> _fillQueue() async {
    logger.debug(
      '$_logTag: Filling URL queue. Current size: ${_urlQueue.length}, Target: ${PrefetchConstants.urlBufferTarget}',
    );
    while (_urlQueue.length < PrefetchConstants.urlBufferTarget) {
      try {
        final url = await dataSource.getImageUrl();
        _urlQueue.add(url);
        _urlStreamController.add(url);
        logger.debug('$_logTag: Added URL to queue. Queue size: ${_urlQueue.length}');
      } catch (e, stackTrace) {
        logger.warning('$_logTag: Failed to get URL for queue', e, stackTrace);
        // If we can't get URLs, break to avoid infinite loop
        break;
      }
    }
    logger.info('$_logTag: Finished filling queue. Final size: ${_urlQueue.length}');
  }

  @override
  Future<Either<Failure, RandomImage>> getNextImage() async {
    if (_isDisposed) {
      logger.warning('$_logTag: Attempted to get next image after disposal');
      return const Left(ServerFailure('Repository has been disposed'));
    }
    logger.debug('$_logTag: Getting next image. Queue size: ${_urlQueue.length}');

    // Ensure queue is initialized
    if (_urlQueue.isEmpty && !_isInitializing) {
      logger.info('$_logTag: Queue is empty, initializing...');
      await _initializeQueue();
    }

    try {
      // Await next URL (from queue if available, otherwise from stream)
      final url = await _getNextUrl();
      logger.debug('$_logTag: Processing image from URL: $url');

      final result = await dataSource.downloadImage(url);
      logger.debug('$_logTag: Image downloaded, extracting colors');

      final extractedColors = await colorExtractor.extractColors(result.bytes);
      logger.info('$_logTag: Successfully processed image. Remaining queue size: ${_urlQueue.length}');

      // Refill queue in background if below target (after image is consumed)
      if (_urlQueue.length < PrefetchConstants.urlBufferTarget && !_isInitializing) {
        logger.debug('$_logTag: Queue below target, refilling in background');
        unawaited(_fillQueue());
      }

      return Right(RandomImage(bytes: result.bytes, extractedColors: extractedColors));
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
    _urlStreamController.close();
    _urlQueue.clear();
  }
}
