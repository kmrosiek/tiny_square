import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/image/image_cubit.dart';

class ImageDisplay extends StatefulWidget {
  const ImageDisplay({required this.imageBytes, super.key});

  final Uint8List imageBytes;

  @override
  State<ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  @override
  Widget build(BuildContext context) {
    final imageProvider = MemoryImage(widget.imageBytes);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImageCubit>().updateColorsFromImage(imageProvider);
    });

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
                widget.imageBytes,
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
