import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';
import '../../domain/entities/extracted_colors.dart';
import '../../domain/services/color_extractor.dart';

class ColorExtractorImpl implements ColorExtractor {
  const ColorExtractorImpl();

  @override
  Future<ExtractedColors> extractColors(Uint8List imageBytes) async {
    final imageProvider = MemoryImage(imageBytes);

    final palette = await PaletteGeneratorMaster.fromImageProvider(
      imageProvider,
      size: const Size(100, 100),
    );

    final lightBg = palette.lightVibrantColor?.color ?? palette.lightMutedColor?.color ?? palette.dominantColor?.color;
    final darkBg = palette.darkVibrantColor?.color ?? palette.darkMutedColor?.color ?? palette.dominantColor?.color;
    final lightText = palette.darkVibrantColor?.color ?? palette.darkMutedColor?.color ?? palette.dominantColor?.color;
    final darkText = palette.lightVibrantColor?.color ?? palette.lightMutedColor?.color ?? palette.dominantColor?.color;

    return ExtractedColors(
      lightBackground: lightBg,
      darkBackground: darkBg,
      lightTextColor: lightText,
      darkTextColor: darkText,
    );
  }
}
