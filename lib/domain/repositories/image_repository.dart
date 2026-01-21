import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/random_image.dart';

abstract class ImageRepository {
  Future<Either<Failure, RandomImage>> getNextImage();
}
