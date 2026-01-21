import '../../domain/entities/random_image.dart';

class RandomImageModel extends RandomImage {
  const RandomImageModel({required super.url});

  factory RandomImageModel.fromUrl(String url) {
    return RandomImageModel(url: url);
  }
}
