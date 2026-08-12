import 'package:flutter/material.dart';
import 'package:visionmusicapp/vision_theme.dart';

/// Clean, flat branded background — no images, no logo overlays.
/// A subtle top-to-bottom dark gradient gives depth without visual clutter,
/// matching the premium minimal feel of Spotify / Apple Music.
class VisionBackground extends StatelessWidget {
  final Widget child;

  // overlayOpacity retained for API compatibility but no longer used.
  // ignore: avoid_unused_constructor_parameters
  const VisionBackground({
    super.key,
    required this.child,
    double overlayOpacity = 0.72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kBackgroundDark, // 0xFF0E0500 — deepest dark at top
            kSurfaceDark, // 0xFF1A0A00 — subtly warmer at bottom
          ],
        ),
      ),
      child: child,
    );
  }
}
