import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../vision_theme.dart';
import '../../../../audio_manager.dart';
import '../../../../now_playing_screen.dart';
import '../../../../widgets/fade_route.dart';
import '../../domain/recognition_state.dart';

class RecognitionResultView extends StatelessWidget {
  final MusicRecognitionResult? result;
  final MusicRecognitionStatus status;
  final VoidCallback onRetry;

  const RecognitionResultView({
    super.key,
    required this.result,
    required this.status,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (status == MusicRecognitionStatus.noMatch || result == null) {
      return _buildNoMatch(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildArtwork(),
          const SizedBox(height: 32),
          Text(
            result!.title ?? 'Unknown Title',
            style: kStyleTitle.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            result!.artist ?? 'Unknown Artist',
            style: kStyleHeadline.copyWith(color: kVisionGold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          if (result!.isInternalMatch)
            _buildPlayButton(context)
          else
            _buildExternalInfo(context),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Identify Another Song',
              style: TextStyle(color: kTextSoft),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusXL),
        child: result!.coverUrl != null
            ? Image.network(
                result!.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildArtworkPlaceholder(),
              )
            : _buildArtworkPlaceholder(),
      ),
    );
  }

  Widget _buildArtworkPlaceholder() {
    return Container(
      color: kSurfaceDark,
      child: const Icon(
        Icons.music_note_rounded,
        size: 80,
        color: kVisionGoldDim,
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          final audioManager = context.read<AudioManager>();
          // In a real scenario, we would find the song in the catalog by ID
          // and call audioManager.playSong(song).
          // For now, if we have a songId, we navigate to the player.
          Navigator.pushReplacement(
            context,
            fadeRoute(NowPlayingScreen(audioManager: audioManager)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kVisionGold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusM),
          ),
        ),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text(
          'PLAY IN VISION MUSIC',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildExternalInfo(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kSurfaceDark,
            borderRadius: BorderRadius.circular(kRadiusM),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: kTextSoft),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Found on Global Catalog. Not yet available in Vision Music.',
                  style: kStyleCaption.copyWith(color: kTextSoft),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoMatch(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 80,
              color: kTextSoft,
            ),
            const SizedBox(height: 24),
            Text(
              "We couldn't identify this song.",
              style: kStyleHeadline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Try moving closer to the speaker or identifying a clearer part of the song.",
              style: kStyleCaption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kVisionGold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadiusM),
                  ),
                ),
                child: const Text(
                  'TRY AGAIN',
                  style: TextStyle(
                    color: kVisionGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
