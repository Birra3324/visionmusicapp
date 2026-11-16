import 'package:visionmusicapp/l10n/listener_strings.dart';
import 'package:flutter/material.dart';
import '../now_playing_screen.dart';
import '../vision_theme.dart';
import '../audio_manager.dart';
import '../song.dart';
import '../widgets/fade_route.dart';
import '../widgets/song_more_options_button.dart';
import 'open_song_video.dart';
import '../core/services/media_source_resolver.dart';

class SongRow extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;
  final String? heroPrefix;
  final Future<void> Function()? onRemoveFromPlaylist;

  const SongRow({
    super.key,
    required this.song,
    required this.audioManager,
    this.heroPrefix,
    this.onRemoveFromPlaylist,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.songPlaybackError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artwork = MediaSourceResolver.artwork(song.imagePath);
    final heroTag = '${heroPrefix ?? ''}artwork-${song.id}';

    return InkWell(
      borderRadius: BorderRadius.circular(kRadiusM),
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
                  ? IconButton(
                      tooltip: context.l10n.watchSong(song.title),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: const Icon(
                        Icons.ondemand_video_rounded,
                        color: kVisionRedText,
                      ),
                      onPressed: () =>
                          openSongVideo(context, song, audioManager),
                    )
                  : Text(
                      _formatDuration(song.duration),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kTextDim, fontSize: 11),
                    ),
            ),
            IconButton(
              tooltip: context.l10n.playSong(song.title),
              iconSize: 26,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.play_arrow_rounded, color: kGoldMid),
              onPressed: () => _onTap(context),
            ),
            SongMoreOptionsButton(
              song: song,
              audioManager: audioManager,
              onRemoveFromPlaylist: onRemoveFromPlaylist,
            ),
          ],
        ),
      ),
    );
  }
}
