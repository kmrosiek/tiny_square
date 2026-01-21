import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/random_image.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/services/color_extractor.dart';
import '../constants/prefetch_constants.dart';
import '../datasources/image_remote_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  ImageRepositoryImpl({required this.dataSource, required this.colorExtractor}) {
    _initializeQueue();
  }

  final ImageRemoteDataSource dataSource;
  final ColorExtractor colorExtractor;
  final Queue<String> _urlQueue = Queue();
  bool _isInitializing = false;

  Future<void> _initializeQueue() async {
    if (_isInitializing) {
      return;
    }
    _isInitializing = true;
    await _fillQueue();
    _isInitializing = false;
  }

  Future<void> _fillQueue() async {
    while (_urlQueue.length < PrefetchConstants.urlBufferTarget) {
      try {
        final url = await dataSource.getImageUrl();
        _urlQueue.add(url);
      } catch (e) {
        // If we can't get URLs, break to avoid infinite loop
        break;
      }
    }
  }

  @override
  Future<Either<Failure, RandomImage>> getNextImage() async {
    // Ensure queue is initialized
    if (_urlQueue.isEmpty && !_isInitializing) {
      await _initializeQueue();
    }

    // Refill queue in background if below target
    if (_urlQueue.length < PrefetchConstants.urlBufferTarget && !_isInitializing) {
      unawaited(_fillQueue());
    }

    if (_urlQueue.isEmpty) {
      return const Left(NetworkFailure('No URLs available'));
    }

    try {
      final url = _urlQueue.removeFirst();
      final result = await dataSource.downloadImage(url);
      final extractedColors = await colorExtractor.extractColors(result.bytes);
      return Right(RandomImage(bytes: result.bytes, extractedColors: extractedColors));
    } on SocketException {
      return const Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
