import 'package:visionmusicapp/l10n/listener_strings.dart';
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
        Text(
          context.l10n.audioCatalogTitle,
          style: TextStyle(
            color: kTextMain,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.audioCatalogDescription,
          style: TextStyle(color: kTextSoft, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onWatch,
          icon: const Icon(Icons.ondemand_video_rounded),
          label: Text(context.l10n.watchMusicVideos),
          style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
      ],
    ),
  );
}
