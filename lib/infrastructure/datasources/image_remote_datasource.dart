import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../core/error/exceptions.dart';
import '../../core/logger/logger.dart';
import '../models/random_image_model.dart';

abstract class ImageRemoteDataSource {
  Future<String> getImageUrl();
  Future<RandomImageModel> downloadImage(String url);
}

class ImageRemoteDataSourceImpl implements ImageRemoteDataSource {
  const ImageRemoteDataSourceImpl({required this.cacheManager, required this.logger});

  static const _logTag = '[ImageRemoteDataSourceImpl]';

  final BaseCacheManager cacheManager;
  final Logger logger;

  static const List<String> _urlList = [
    'https://fastly.picsum.photos/id/905/2048/2048.jpg?hmac=BnS9B46WuQAfAbZ2Q8u77RPJZb9fbDoRCsmt76T8G7Q',
    'https://images.unsplash.com/photo-1504198266285-165a9f3539a5',
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
      // Mocking the API response for now as requested in the plan
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final url = _urlList[_currentIndex++ % _urlList.length];

      logger.info('$_logTag: Successfully fetched image URL: $url');
      return url;
    } catch (e, stackTrace) {
      logger.error('$_logTag: Error fetching image URL', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<RandomImageModel> downloadImage(String url) async {
    try {
      final file = await cacheManager.getSingleFile(url);
      final bytes = await file.readAsBytes();
      return RandomImageModel.fromBytes(bytes);
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
