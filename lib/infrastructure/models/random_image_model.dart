import '../../domain/entities/random_image.dart';

class RandomImageModel extends RandomImage {
  const RandomImageModel({required super.url});

  factory RandomImageModel.fromJson(Map<String, dynamic> json) {
    return RandomImageModel(url: json['url'] as String);
  }
}
