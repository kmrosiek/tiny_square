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

  final ImageRemoteDataSource dataSource;
  final ColorExtractor colorExtractor;
  final Logger logger;
  final Queue<String> _urlQueue = Queue();
  bool _isInitializing = false;

  Future<void> _initializeQueue() async {
    if (_isInitializing) {
      logger.debug('Queue initialization already in progress');
      return;
    }
    logger.debug('Initializing URL queue');
    _isInitializing = true;
    await _fillQueue();
    _isInitializing = false;
    logger.info('URL queue initialized with ${_urlQueue.length} URLs');
  }

  Future<void> _fillQueue() async {
    logger.debug('Filling URL queue. Current size: ${_urlQueue.length}, Target: ${PrefetchConstants.urlBufferTarget}');
    while (_urlQueue.length < PrefetchConstants.urlBufferTarget) {
      try {
        final url = await dataSource.getImageUrl();
        _urlQueue.add(url);
        logger.debug('Added URL to queue. Queue size: ${_urlQueue.length}');
      } catch (e, stackTrace) {
        logger.warning('Failed to get URL for queue', e, stackTrace);
        // If we can't get URLs, break to avoid infinite loop
        break;
      }
    }
    logger.info('Finished filling queue. Final size: ${_urlQueue.length}');
  }

  @override
  Future<Either<Failure, RandomImage>> getNextImage() async {
    logger.debug('Getting next image. Queue size: ${_urlQueue.length}');

    // Ensure queue is initialized
    if (_urlQueue.isEmpty && !_isInitializing) {
      logger.info('Queue is empty, initializing...');
      await _initializeQueue();
    }

    // Refill queue in background if below target
    if (_urlQueue.length < PrefetchConstants.urlBufferTarget && !_isInitializing) {
      logger.debug('Queue below target, refilling in background');
      unawaited(_fillQueue());
    }

    if (_urlQueue.isEmpty) {
      logger.warning('No URLs available in queue');
      return const Left(NetworkFailure('No URLs available'));
    }

    try {
      final url = _urlQueue.removeFirst();
      logger.debug('Processing image from URL: $url');

      final result = await dataSource.downloadImage(url);
      logger.debug('Image downloaded, extracting colors');

      final extractedColors = await colorExtractor.extractColors(result.bytes);
      logger.info('Successfully processed image. Remaining queue size: ${_urlQueue.length}');

      return Right(RandomImage(bytes: result.bytes, extractedColors: extractedColors));
    } on SocketException catch (e, stackTrace) {
      logger.error('Network error while getting next image', e, stackTrace);
      return const Left(NetworkFailure('No internet connection'));
    } catch (e, stackTrace) {
      logger.error('Error getting next image', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }
}
