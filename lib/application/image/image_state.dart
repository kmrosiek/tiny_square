import 'package:flutter/material.dart';

sealed class ImageState {
  const ImageState();
}

class ImageInitial extends ImageState {
  const ImageInitial();
}

class ImageLoading extends ImageState {
  const ImageLoading();
}

class ImageLoaded extends ImageState {
  final String imageUrl;
  final Color backgroundColor;
  final Color textColor;

  const ImageLoaded({
    required this.imageUrl,
    required this.backgroundColor,
    required this.textColor,
  });
}

class ImageError extends ImageState {
  final String message;

  const ImageError({required this.message});
}
