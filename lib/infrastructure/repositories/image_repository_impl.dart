import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/random_image.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_remote_datasource.dart';

class ImageRepositoryImpl implements ImageRepository {
  const ImageRepositoryImpl({required this.dataSource});

  final ImageRemoteDataSource dataSource;

  @override
  Future<Either<Failure, RandomImage>> getRandomImage() async {
    try {
      final result = await dataSource.getRandomImage();
      return Right(result);
    } on SocketException {
      return const Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
