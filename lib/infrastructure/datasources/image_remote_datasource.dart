import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as client;
import 'package:tiny_square/core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/logger/logger.dart';

abstract class ImageRemoteDataSource {
  Future<String> getImageUrl();
  Future<Uint8List> downloadImage(String url);
}

class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  const ImageRemoteDataSourceImpl({required this.cacheManager, required this.logger});

  static const _logTag = '[ImageRemoteDataSourceImpl]';

  final BaseCacheManager cacheManager;
  final Logger logger;

  @override
  Future<String> getImageUrl() async {
    logger.debug('$_logTag: Fetching image URL');
    final response = await client.get(Uri.parse('${ApiConstants.baseUrl}/image/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load image URL: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final imageUrl = json['url'] as String;
    return imageUrl;
  }

  @override
  Future<Uint8List> downloadImage(String url) async {
    try {
      final file = await cacheManager.getSingleFile(url);
      final bytes = await file.readAsBytes();
      return bytes;
    } on HttpExceptionWithStatus catch (e) {
      if (e.statusCode == 404) {
        throw ImageNotFoundException(url);
      }
      rethrow;
    } catch (e) {
      logger.error('$_logTag: Error downloading image from URL: $url', e);
      rethrow;
    }
  }
}
