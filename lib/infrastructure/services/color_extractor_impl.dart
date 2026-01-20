import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';
import '../../domain/services/color_extractor.dart';

class ColorExtractorImpl implements ColorExtractor {
  const ColorExtractorImpl();

  @override
  Future<Color?> extractDominantColor(ImageProvider imageProvider) async {
    final paletteGenerator = await PaletteGeneratorMaster.fromImageProvider(
      imageProvider,
      size: const Size(100, 100),
    );

    return paletteGenerator.dominantColor?.color ?? paletteGenerator.vibrantColor?.color;
  }
}
