import 'package:flutter/material.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/now_playing_screen.dart';
import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/fade_route.dart';
import 'package:visionmusicapp/core/services/media_source_resolver.dart';

/// Persistent player that sits directly above the bottom navigation whenever
/// audio is loaded.
///
/// Every element is driven by real player state: the title, artist and artwork
/// come from `currentSongStream`, the progress bar from `positionStream` and
/// `durationStream`, and the play/pause icon from `isPlayingStream`. Nothing
/// here is decorative.
class MiniPlayer extends StatelessWidget {
  final AudioManager audioManager;

  const MiniPlayer({super.key, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    // currentSongStream is the authoritative source — ListenableBuilder alone
    // would miss track changes that don't call notifyListeners().
    return StreamBuilder<Song?>(
      stream: audioManager.currentSongStream,
      initialData: audioManager.currentSong,
      builder: (context, songSnap) {
        final song = songSnap.data ?? audioManager.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            fadeRoute(NowPlayingScreen(audioManager: audioManager)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: kSurfaceDark,
              borderRadius: BorderRadius.circular(kRadiusM),
              border: Border.all(
                color: kVisionGold.withValues(alpha: 0.22),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusM),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProgressBar(audioManager: audioManager),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      kSpaceXS,
                      kSpaceXS,
                      kSpaceS,
                      kSpaceXS,
                    ),
                    child: Row(
                      children: [
                        _Artwork(song: song),
                        const SizedBox(width: kSpaceS),
                        Expanded(child: _TitleBlock(song: song)),
                        const SizedBox(width: kSpaceXS),
                        _Controls(audioManager: audioManager),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Thin gold progress line along the top edge ───────────────────────────────

class _ProgressBar extends StatelessWidget {
  final AudioManager audioManager;
  const _ProgressBar({required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: audioManager.positionStream,
      builder: (context, posSnap) {
        return StreamBuilder<Duration?>(
          stream: audioManager.durationStream,
          builder: (context, durSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final dur = durSnap.data ?? Duration.zero;
            final progress = dur.inMilliseconds == 0
                ? 0.0
                : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
            return LinearProgressIndicator(
              value: progress,
              minHeight: 2.5,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(kVisionGoldLight),
            );
          },
        );
      },
    );
  }
}

// ─── Artwork ──────────────────────────────────────────────────────────────────

class _Artwork extends StatelessWidget {
  final Song song;
  const _Artwork({required this.song});

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusXS),
      child: Image(
        // Decode at display size rather than full resolution.
        image: ResizeImage.resizeIfNeeded(
          (size * 3).round(),
          null,
          MediaSourceResolver.artwork(song.imagePath),
        ),
        width: size,
        height: size,
        // Never distort cover art.
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          color: kCardBlack,
          child: const Icon(
            Icons.music_note_rounded,
            color: kVisionGold,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ─── Title + artist ───────────────────────────────────────────────────────────

class _TitleBlock extends StatelessWidget {
  final Song song;
  const _TitleBlock({required this.song});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: kTextMain,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kTextSoft, fontSize: 12, height: 1.2),
        ),
      ],
    );
  }
}

// ─── Transport controls ───────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  final AudioManager audioManager;
  const _Controls({required this.audioManager});

  @override
  Widget build(BuildContext context) {
    // Previous and queue are dropped on very narrow screens rather than allowed
    // to overflow. Play/pause and next always survive.
    final width = MediaQuery.sizeOf(context).width;
    final showPrevious = width >= 340;
    final showQueue = width >= 380;

    return StreamBuilder<bool>(
      stream: audioManager.isPlayingStream,
      initialData: audioManager.isPlaying,
      builder: (context, snap) {
        final playing = snap.data ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showPrevious)
              _IconButton(
                icon: Icons.skip_previous_rounded,
                onTap: audioManager.skipToPrevious,
              ),
            // Strongest gold emphasis sits on play/pause.
            GestureDetector(
              onTap: audioManager.togglePlayPause,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: kSpaceXXS),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kVisionGold,
                ),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
            _IconButton(
              icon: Icons.skip_next_rounded,
              onTap: audioManager.skipToNext,
            ),
            if (showQueue)
              _IconButton(
                icon: Icons.queue_music_rounded,
                onTap: () => _showQueue(context),
              ),
          ],
        );
      },
    );
  }

  void _showQueue(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kSurfaceDark,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusL)),
      ),
      builder: (sheetContext) => _QueueSheet(audioManager: audioManager),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpaceXXS, vertical: 6),
        child: Icon(icon, color: kTextSoft, size: 24),
      ),
    );
  }
}

// ─── Queue sheet ──────────────────────────────────────────────────────────────

class _QueueSheet extends StatelessWidget {
  final AudioManager audioManager;
  const _QueueSheet({required this.audioManager});

  @override
  Widget build(BuildContext context) {
    final tracks = audioManager.tracks;
    final current = audioManager.currentSong;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(kSpaceL, 0, kSpaceL, kSpaceS),
              child: Text('Up next', style: kStyleHeadline),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tracks.length,
                itemBuilder: (context, i) {
                  final song = tracks[i];
                  final isCurrent = song == current;
                  return ListTile(
                    dense: true,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(kRadiusXS),
                      child: Image(
                        image: ResizeImage.resizeIfNeeded(
                          120,
                          null,
                          MediaSourceResolver.artwork(song.imagePath),
                        ),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Container(width: 40, height: 40, color: kCardBlack),
                      ),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent ? kVisionGoldLight : kTextMain,
                        fontSize: 14,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kTextSoft, fontSize: 12),
                    ),
                    trailing: isCurrent
                        ? const Icon(
                            Icons.equalizer_rounded,
                            color: kVisionGoldLight,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      audioManager.playSong(song);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
