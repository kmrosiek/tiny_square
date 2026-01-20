import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  const ImageDisplay({required this.imageBytes, super.key});

  final Uint8List imageBytes;

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
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.shade300, child: const Icon(Icons.error, size: 48)),
              ),
            ),
          ),
        );
      },
    );
  }
}
