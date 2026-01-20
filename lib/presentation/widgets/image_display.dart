import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/image/image_cubit.dart';

class ImageDisplay extends StatefulWidget {
  const ImageDisplay({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  State<ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight * 0.8;

        return Semantics(
          image: true,
          label: 'Random image',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: size,
              height: size,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey.shade300, child: const Icon(Icons.error, size: 48)),
                imageBuilder: (context, imageProvider) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<ImageCubit>().updateColorsFromImage(imageProvider);
                  });
                  return Image(image: imageProvider, fit: BoxFit.cover);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
