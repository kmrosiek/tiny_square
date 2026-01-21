import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import '../../core/logger/logger.dart';
import '../models/random_image_model.dart';

abstract class ImageRemoteDataSource {
  Future<String> getImageUrl();
  Future<RandomImageModel> downloadImage(String url);
}

class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  const ImageRemoteDataSourceImpl({required this.client, required this.cacheManager, required this.logger});

  static const _logTag = '[ImageRemoteDataSourceImpl]';

  final http.Client client;
  final BaseCacheManager cacheManager;
  final Logger logger;

  static const List<String> _urlList = [
    'https://fastly.picsum.photos/id/905/2048/2048.jpg?hmac=BnS9B46WuQAfAbZ2Q8u77RPJZb9fbDoRCsmt76T8G7Q',
    'https://fastly.picsum.photos/id/182/2048/2048.jpg?hmac=fMWIKh38B7NC1b31mBrj9jQR71pVU-fy8E31aks_wbY',
    'https://fastly.picsum.photos/id/555/2048/2048.jpg?hmac=DijiNTFJhVeA2St8T_BlviZ7XyJzbrdlj5Q5LhVMJcc',
    'https://fastly.picsum.photos/id/237/2048/2048.jpg?hmac=AT_slCrwHbSjUao6khSaynxk6evW7RVNxZXCiCWDh2A',
    'https://fastly.picsum.photos/id/1003/2048/2048.jpg?hmac=1aUV_jTbgJZQx0eITKQil3b1SmYCMtUxXwzBmsQXcfQ',
    'https://fastly.picsum.photos/id/822/2048/2048.jpg?hmac=3HIJGNfXDCyvs6yyMUNymbux7_CC0Xqdn0P2-QdW4xM',
    'https://fastly.picsum.photos/id/91/2048/2048.jpg?hmac=tlQbEOjAwdAw6-EGjxUCe_RhsMvhQMzarjdgDXqu3T8',
  ];

  static int _currentIndex = 0;

  @override
  Future<String> getImageUrl() async {
    logger.debug('$_logTag: Fetching image URL $_currentIndex');
    try {
      //final response = await client.get(Uri.parse('${ApiConstants.baseUrl}/image/'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final response = http.Response('{"url": "${_urlList[_currentIndex++ % _urlList.length]}"}', 200);

      if (response.statusCode != 200) {
        logger.error('$_logTag: Failed to load image URL', Exception('Status code: ${response.statusCode}'));
        throw Exception('Failed to load image URL: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final url = json['url'] as String;
      logger.info('$_logTag: Successfully fetched image URL: $url');
      return url;
    } catch (e, stackTrace) {
      logger.error('$_logTag: Error fetching image URL', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<RandomImageModel> downloadImage(String url) async {
    logger.debug('$_logTag: Downloading image from URL: $url');
    try {
      final file = await cacheManager.getSingleFile(url);
      final bytes = await file.readAsBytes();

      logger.info('$_logTag: Successfully downloaded/retrieved image from cache: $url');
      return RandomImageModel.fromBytes(bytes);
    } catch (e, stackTrace) {
      logger.error('$_logTag: Error downloading image from URL: $url', e, stackTrace);
      rethrow;
    }
  }
}
