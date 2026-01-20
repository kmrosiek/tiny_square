import 'package:flutter/material.dart';

class ImageState {
  const ImageState({
    this.isLoading = false,
    this.imageUrl,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.errorMessage,
  });
  final bool isLoading;
  final String? imageUrl;
  final Color backgroundColor;
  final Color textColor;
  final String? errorMessage;

  ImageState copyWith({
    bool? isLoading,
    String? imageUrl,
    Color? backgroundColor,
    Color? textColor,
    String? errorMessage,
  }) {
    return ImageState(
      isLoading: isLoading ?? this.isLoading,
      imageUrl: imageUrl ?? this.imageUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
