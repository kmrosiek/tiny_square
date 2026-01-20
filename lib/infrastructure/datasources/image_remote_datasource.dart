import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/random_image_model.dart';

abstract class ImageRemoteDataSource {
  Future<RandomImageModel> getRandomImage();
}

class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'https://november7-730026606190.europe-west1.run.app';

  ImageRemoteDataSourceImpl({required this.client});

  @override
  Future<RandomImageModel> getRandomImage() async {
    final response = await client.get(Uri.parse('$_baseUrl/image/'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return RandomImageModel.fromJson(json);
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }
}
