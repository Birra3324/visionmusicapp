import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/features/lyrics/lyrics_service.dart';
import 'package:visionmusicapp/core/services/media_source_resolver.dart';
import 'package:visionmusicapp/widgets/song_more_options_button.dart';

class NowPlayingScreen extends StatefulWidget {
  final AudioManager audioManager;

  const NowPlayingScreen({super.key, required this.audioManager});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showLyricsSheet(BuildContext context, Song song) {
    final settingsManager = context.read<SettingsManager>();

    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lyrics',
                    style: TextStyle(
                      color: kTextMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.title,
                    style: const TextStyle(color: kTextSoft, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<String?>(
                      future: LyricsService().getLyrics(
                        song.id,
                        song.title,
                        languageCode: settingsManager.localeCode,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // "Loading", not "Generating". Nothing is generated,
                          // and saying so implied a transcription that never
                          // happened.
                          return const Center(
                            child: CircularProgressIndicator(
                              color: kVisionGold,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const _LyricsMessage(
                            icon: Icons.error_outline_rounded,
                            title: 'Could not load lyrics',
                            detail: 'Please try again in a moment.',
                          );
                        }
                        final lyrics = snapshot.data;
                        if (lyrics == null || lyrics.trim().isEmpty) {
                          // Honest empty state. This screen used to display
                          // invented lyrics for real artists' songs; showing
                          // nothing is strictly better than showing fiction.
                          return const _LyricsMessage(
                            icon: Icons.lyrics_outlined,
                            title: 'Lyrics not available yet',
                            detail:
                                'We only show lyrics provided by the artist or '
                                'a licensed source.',
                          );
                        }
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: Text(
                            lyrics,
                            style: const TextStyle(
                              color: kTextMain,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showVolumeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double currentVolume = widget.audioManager.volume;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Volume',
                    style: TextStyle(
                      color: kTextMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.volume_mute_rounded, color: kTextSoft),
                      Expanded(
                        child: Slider(
                          min: 0,
                          max: 1,
                          value: currentVolume.clamp(0.0, 1.0),
                          activeColor: kVisionGoldLight,
                          inactiveColor: Colors.white24,
                          onChanged: (v) {
                            setModalState(() => currentVolume = v);
                            widget.audioManager.setVolume(v);
                          },
                        ),
                      ),
                      const Icon(Icons.volume_up_rounded, color: kTextSoft),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMilliseconds <= 0) return '00:00';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Song?>(
      stream: widget.audioManager.currentSongStream,
      initialData: widget.audioManager.currentSong,
      builder: (context, snapshot) {
        final song = snapshot.data;

        if (song == null) {
          return const Scaffold(
            backgroundColor: kDarkBackground,
            body: Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: kTextMain),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: kDarkBackground,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (song.imagePath != null)
                FadeTransition(
                  opacity: _animationController,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.60),
                        BlendMode.darken,
                      ),
                      child: Image(
                        image: MediaSourceResolver.artwork(song.imagePath),
                        fit: BoxFit.cover,
                        key: ValueKey(song.imagePath),
                      ),
                    ),
                  ),
                )
              else
                Container(color: kDarkBackground),

              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // TOP: scrollable content (header, artwork, titles)
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: kTextMain,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  Expanded(
                                    child: Text(
                                      song.title,
                                      style: const TextStyle(
                                        color: kTextMain,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Hero(
                              tag: 'artwork_${song.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: SizedBox(
                                  height: 320,
                                  width: 320,
                                  child: Image(
                                    image: MediaSourceResolver.artwork(
                                      song.imagePath,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    song.title,
                                    style: const TextStyle(
                                      color: kTextMain,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song.artist,
                                    style: const TextStyle(
                                      color: kTextSoft,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),
                    // BOTTOM: waveform + time + controls (lifted slightly above bottom)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        0,
                        24,
                        10 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder<Duration>(
                            stream: widget.audioManager.positionStream,
                            initialData: Duration.zero,
                            builder: (context, posSnap) {
                              return StreamBuilder<Duration?>(
                                stream: widget.audioManager.durationStream,
                                initialData: Duration.zero,
                                builder: (context, durSnap) {
                                  final pos = posSnap.data ?? Duration.zero;
                                  final dur = durSnap.data ?? Duration.zero;

                                  return _StaticWaveSeekBar(
                                    progress: (dur.inMilliseconds == 0)
                                        ? 0.0
                                        : (pos.inMilliseconds /
                                                  dur.inMilliseconds)
                                              .clamp(0.0, 1.0),
                                    enabled: dur.inMilliseconds > 0,
                                    seed: song.id.hashCode,
                                    onSeekFraction: (fraction) {
                                      if (dur.inMilliseconds <= 0) return;
                                      final seekTo = Duration(
                                        milliseconds:
                                            (fraction * dur.inMilliseconds)
                                                .round(),
                                      );
                                      widget.audioManager.seek(seekTo);
                                    },
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          StreamBuilder<Duration>(
                            stream: widget.audioManager.positionStream,
                            initialData: Duration.zero,
                            builder: (context, posSnap) {
                              return StreamBuilder<Duration?>(
                                stream: widget.audioManager.durationStream,
                                initialData: Duration.zero,
                                builder: (context, durSnap) {
                                  final position =
                                      posSnap.data ?? Duration.zero;
                                  final total = durSnap.data ?? Duration.zero;

                                  return Row(
                                    children: [
                                      Text(
                                        _formatDuration(position),
                                        style: const TextStyle(
                                          color: kTextSoft,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatDuration(total),
                                        style: const TextStyle(
                                          color: kTextSoft,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          StreamBuilder<bool>(
                            stream: widget.audioManager.shuffleEnabledStream,
                            initialData: false,
                            builder: (context, shuffleSnap) {
                              final shuffleOn = shuffleSnap.data ?? false;
                              return StreamBuilder<LoopMode>(
                                stream: widget.audioManager.loopModeStream,
                                initialData: LoopMode.off,
                                builder: (context, loopSnap) {
                                  final loopMode =
                                      loopSnap.data ?? LoopMode.off;
                                  IconData repeatIcon;
                                  Color repeatColor;

                                  switch (loopMode) {
                                    case LoopMode.one:
                                      repeatIcon = Icons.repeat_one_rounded;
                                      repeatColor = kVisionGoldLight;
                                      break;
                                    case LoopMode.all:
                                      repeatIcon = Icons.repeat_rounded;
                                      repeatColor = kVisionGoldLight;
                                      break;
                                    case LoopMode.off:
                                      repeatIcon = Icons.repeat_rounded;
                                      repeatColor = Colors.white54;
                                  }

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Primary Playback Controls
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.skip_previous_rounded,
                                            ),
                                            iconSize: 42,
                                            color: Colors.white,
                                            onPressed: () => widget.audioManager
                                                .skipToPrevious(),
                                          ),
                                          const SizedBox(width: 24),
                                          StreamBuilder<bool>(
                                            stream: widget
                                                .audioManager
                                                .isPlayingStream,
                                            initialData:
                                                widget.audioManager.isPlaying,
                                            builder: (context, isPlayingSnap) {
                                              return SizedBox(
                                                height: 72,
                                                width: 72,
                                                child: FloatingActionButton(
                                                  onPressed: () => widget
                                                      .audioManager
                                                      .togglePlayPause(),
                                                  backgroundColor:
                                                      kVisionGoldLight,
                                                  elevation: 2,
                                                  shape: const CircleBorder(),
                                                  child: Icon(
                                                    isPlayingSnap.data == true
                                                        ? Icons.pause_rounded
                                                        : Icons
                                                              .play_arrow_rounded,
                                                    color: Colors.black,
                                                    size: 40,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 24),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.skip_next_rounded,
                                            ),
                                            iconSize: 42,
                                            color: Colors.white,
                                            onPressed: () => widget.audioManager
                                                .skipToNext(),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // Secondary Actions
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.volume_down_rounded,
                                            ),
                                            color: kTextSoft,
                                            onPressed: () =>
                                                _showVolumeSheet(context),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.shuffle_rounded,
                                              color: shuffleOn
                                                  ? kVisionGoldLight
                                                  : Colors.white54,
                                            ),
                                            onPressed: () => widget.audioManager
                                                .toggleShuffle(),
                                          ),
                                          SongMoreOptionsButton(
                                            song: song,
                                            audioManager: widget.audioManager,
                                            iconSize: 26,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              repeatIcon,
                                              color: repeatColor,
                                            ),
                                            onPressed: () => widget.audioManager
                                                .cycleRepeatMode(),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.lyrics_outlined,
                                            ),
                                            color: kTextSoft,
                                            onPressed: () =>
                                                _showLyricsSheet(context, song),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StaticWaveSeekBar extends StatelessWidget {
  final double progress;
  final bool enabled;
  final int seed;
  final ValueChanged<double> onSeekFraction;

  const _StaticWaveSeekBar({
    required this.progress,
    required this.enabled,
    required this.seed,
    required this.onSeekFraction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        void seek(Offset localPosition) {
          if (!enabled || constraints.maxWidth <= 0) return;
          final fraction = (localPosition.dx / constraints.maxWidth).clamp(
            0.0,
            1.0,
          );
          onSeekFraction(fraction);
        }

        return Semantics(
          label: 'Playback position',
          value: '${(progress * 100).round()} percent',
          slider: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => seek(details.localPosition),
            onHorizontalDragUpdate: (details) => seek(details.localPosition),
            child: SizedBox(
              height: 24,
              width: double.infinity,
              child: CustomPaint(
                painter: _StaticWavePainter(
                  progress: progress,
                  seed: seed,
                  enabled: enabled,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StaticWavePainter extends CustomPainter {
  final double progress;
  final int seed;
  final bool enabled;

  const _StaticWavePainter({
    required this.progress,
    required this.seed,
    required this.enabled,
  });

  double _heightFor(int index) {
    var value = index * 374761393 + seed * 668265263;
    value = (value ^ (value >> 13)) * 1274126177;
    value ^= value >> 16;
    final noise = (value & 0xFFFF) / 0xFFFF;
    return 5 + noise * 13;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final playedPaint = Paint()
      ..color = enabled ? kVisionGoldLight : kVisionGoldDim
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final remainingPaint = Paint()
      ..color = enabled ? Colors.white30 : Colors.white12
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barCount = (size.width / 7).floor().clamp(32, 60);
    final spacing = size.width / barCount;
    final centerY = size.height / 2;
    final playedX = progress.clamp(0.0, 1.0) * size.width;

    for (var i = 0; i < barCount; i++) {
      final x = spacing * (i + 0.5);
      final barHeight = _heightFor(i).clamp(5.0, size.height - 4);
      final paint = x <= playedX ? playedPaint : remainingPaint;
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StaticWavePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.seed != seed ||
      oldDelegate.enabled != enabled;
}

/// Shared empty / error state for the lyrics sheet.
class _LyricsMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _LyricsMessage({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kVisionGoldDim, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextMain,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTextSoft,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
