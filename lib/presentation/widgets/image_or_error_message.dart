import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tiny_square/presentation/consts/homepage_constants.dart';
import 'package:tiny_square/presentation/widgets/error_message.dart';

class ImageOrErrorMessage extends StatelessWidget {
  const ImageOrErrorMessage({
    super.key,
    required this.isLoading,
    required this.cacheManager,
    this.errorMessage,
    this.imageUrl,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? imageUrl;
  final BaseCacheManager cacheManager;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedSwitcher(
        duration: HomepageConstants.fadeInOutDuration,
        child: isLoading
            ? const SizedBox.shrink(key: ValueKey('loading'))
            : errorMessage != null || imageUrl == null
            ? ErrorMessage(message: errorMessage ?? 'No image')
            : Center(
                key: ValueKey(imageUrl),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  cacheManager: cacheManager,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  memCacheWidth: 1024, // Decoded RAM optimization
                  placeholder: (context, url) => const SizedBox.shrink(),
                  errorWidget: (context, url, error) => const ErrorMessage(message: 'Failed to display image'),
                ),
              ),
      ),
    );
  }
}
