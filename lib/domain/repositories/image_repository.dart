import '../entities/random_image.dart';

abstract class ImageRepository {
  Future<RandomImage> getRandomImage();
}
