import 'package:flutter/material.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/now_playing_screen.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/fade_route.dart';

class MiniPlayer extends StatelessWidget {
  final AudioManager audioManager;

  const MiniPlayer({super.key, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioManager,
      builder: (context, _) {
        final song = audioManager.currentSong;

        if (song == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            fadeRoute(NowPlayingScreen(audioManager: audioManager)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: kDarkCard, // your dark card color
            ),
            child: Row(
              children: [
                // Artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    song.imagePath ?? 'assets/images/visionlogo.jpg',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 12),

                // Title/artist (fills the middle cleanly)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: kTextSoft),
                      ),
                    ],
                  ),
                ),

                // Controls (no extra Spacer before this)
                IconButton(
                  icon: Icon(
                    audioManager.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () => audioManager.togglePlayPause(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => audioManager.skipToNext(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
