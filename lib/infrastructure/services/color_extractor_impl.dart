import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:palette_generator_master/palette_generator_master.dart';

import '../../domain/entities/extracted_colors.dart';
import '../../domain/services/color_extractor.dart';

class ColorExtractorImpl implements ColorExtractor {
  @override
  Future<ExtractedColors> extractColors(Uint8List imageBytes) async {
    final result = await Isolate.run(() => _extractColorsTask(imageBytes));
    return ExtractedColors(
      lightBackground: result.$1 != null ? Color(result.$1!) : null,
      darkBackground: result.$2 != null ? Color(result.$2!) : null,
      lightTextColor: result.$3 != null ? Color(result.$3!) : null,
      darkTextColor: result.$4 != null ? Color(result.$4!) : null,
    );
  }
}

Future<(int?, int?, int?, int?)> _extractColorsTask(Uint8List imageBytes) async {
  final image = img.decodeImage(imageBytes);
  if (image == null) {
    return (null, null, null, null);
  }

  final thumbnail = img.copyResize(image, width: 120);

  final Map<int, int> pixelCounts = {};

  for (final pixel in thumbnail) {
    final int a = pixel.a.toInt();
    final int r = pixel.r.toInt();
    final int g = pixel.g.toInt();
    final int b = pixel.b.toInt();

    final int argb = (a << 24) | (r << 16) | (g << 8) | b;

    pixelCounts[argb] = (pixelCounts[argb] ?? 0) + 1;
  }

  final List<PaletteColorMaster> paletteColors = pixelCounts.entries.map((entry) {
    return PaletteColorMaster(Color(entry.key), entry.value);
  }).toList();

  final palette = PaletteGeneratorMaster.fromColors(paletteColors);

  final lightBg = palette.lightVibrantColor?.color ?? palette.lightMutedColor?.color ?? palette.dominantColor?.color;
  final darkBg = palette.darkVibrantColor?.color ?? palette.darkMutedColor?.color ?? palette.dominantColor?.color;
  final lightText = palette.darkVibrantColor?.color ?? palette.darkMutedColor?.color ?? palette.dominantColor?.color;
  final darkText = palette.lightVibrantColor?.color ?? palette.lightMutedColor?.color ?? palette.dominantColor?.color;

  return (lightBg?.toARGB32(), darkBg?.toARGB32(), lightText?.toARGB32(), darkText?.toARGB32());
}
