import 'package:flutter/material.dart';
import '../vision_theme.dart';

class AudioCatalogEmptyState extends StatelessWidget {
  const AudioCatalogEmptyState({super.key, required this.onWatch});

  final VoidCallback? onWatch;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: kCardBlack,
      borderRadius: BorderRadius.circular(kRadiusM),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.headphones_rounded, color: kVisionGold, size: 32),
        const SizedBox(height: 16),
        const Text(
          'Our audio catalog is on its way',
          style: TextStyle(
            color: kTextMain,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Explore Vision Entertainment’s official music videos while we prepare the audio releases.',
          style: TextStyle(color: kTextSoft, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onWatch,
          icon: const Icon(Icons.ondemand_video_rounded),
          label: const Text('Watch music videos'),
          style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
      ],
    ),
  );
}
