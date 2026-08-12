import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';

class ArtworkPalette {
  final Color primary;
  final Color secondary;

  ArtworkPalette({required this.primary, required this.secondary});
}

Future<ArtworkPalette> generatePalette(String assetPath) async {
  final imageProvider = AssetImage(assetPath);
  final palette = await PaletteGenerator.fromImageProvider(
    imageProvider,
    maximumColorCount: 16,
  );
  final dominant = palette.dominantColor?.color ?? const Color(0xFF1E1E1E);
  final vibrant =
      palette.vibrantColor?.color ??
      palette.lightVibrantColor?.color ??
      dominant.withOpacity(0.7);

  return ArtworkPalette(primary: dominant, secondary: vibrant);
}
