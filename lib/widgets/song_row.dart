import 'package:flutter/material.dart';
import '../now_playing_screen.dart';
import '../vision_theme.dart';
import '../audio_manager.dart';
import '../song.dart';
import '../widgets/fade_route.dart';
import '../widgets/song_more_options_button.dart';
import '../core/services/media_source_resolver.dart';

class SongRow extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;
  final String? heroPrefix;

  const SongRow({
    super.key,
    required this.song,
    required this.audioManager,
    this.heroPrefix,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onTap(BuildContext context) async {
    try {
      if (audioManager.currentSong != song) {
        await audioManager.playSong(song);
      }
      if (context.mounted) {
        Navigator.push(
          context,
          fadeRoute(NowPlayingScreen(audioManager: audioManager)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This song could not be played.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artwork = MediaSourceResolver.artwork(song.imagePath);
    final heroTag = '${heroPrefix ?? ''}artwork-${song.id}';

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: kSpaceXS),
        padding: const EdgeInsets.symmetric(horizontal: kSpaceS, vertical: 8),
        decoration: BoxDecoration(
          color: kCardBlack.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(kRadiusM),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: heroTag,
                child: Image(
                  image: ResizeImage.resizeIfNeeded(156, null, artwork),
                  height: 52,
                  width: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 52,
                    width: 52,
                    color: kCardBlack,
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: kVisionGoldDim,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: kSpaceS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextSoft,
                      fontSize: 12,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: kSpaceXS),
            SizedBox(
              width: 62,
              child: song.youtubeUrl != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'VIDEO',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      _formatDuration(song.duration),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kTextDim, fontSize: 11),
                    ),
            ),
            IconButton(
              iconSize: 26,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.play_arrow_rounded, color: kGoldMid),
              onPressed: () => _onTap(context),
            ),
            SongMoreOptionsButton(
              song: song,
              audioManager: audioManager,
            ),
          ],
        ),
      ),
    );
  }
}
