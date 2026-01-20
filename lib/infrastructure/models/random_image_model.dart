import 'dart:typed_data';
import '../../domain/entities/random_image.dart';

class RandomImageModel extends RandomImage {
  const RandomImageModel({required super.bytes});

  factory RandomImageModel.fromBytes(Uint8List bytes) {
    return RandomImageModel(bytes: bytes);
  }
}
