import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/random_image_model.dart';

abstract class ImageRemoteDataSource {
  Future<RandomImageModel> getRandomImage();
}

class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  const ImageRemoteDataSourceImpl({required this.client});
  final http.Client client;

  @override
  Future<RandomImageModel> getRandomImage() async {
    final response = await client.get(Uri.parse('${ApiConstants.baseUrl}/image/'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return RandomImageModel.fromJson(json);
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }
}
