import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiny_square/presentation/widgets/error_message.dart';

class ImageOrErrorMessage extends StatelessWidget {
  const ImageOrErrorMessage({super.key, required this.isLoading, this.errorMessage, this.imageBytes});

  final bool isLoading;
  final String? errorMessage;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: isLoading
          ? const SizedBox.shrink()
          : errorMessage != null
          ? ErrorMessage(message: errorMessage!)
          : Image.memory(imageBytes!, key: ValueKey(imageBytes!.hashCode), fit: BoxFit.cover, gaplessPlayback: true),
    );
  }
}
