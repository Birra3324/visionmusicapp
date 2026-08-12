import 'package:flutter/material.dart';

import '../audio_manager.dart';
import '../song.dart';
import '../vision_theme.dart';
import '../now_playing_screen.dart'; // NowPlayingScreen

class MiniPlayerBar extends StatelessWidget {
  final AudioManager audioManager;

  const MiniPlayerBar({super.key, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    // Use a StreamBuilder to check if there is a song playing
    return StreamBuilder<Song?>(
      stream: audioManager.currentSongStream, // Assuming this stream exists
      builder: (context, snapshot) {
        final Song? song = snapshot.data;
        if (song == null) {
          return const SizedBox.shrink(); // Show nothing if no song is playing
        }

        return StreamBuilder<bool>(
          stream: audioManager.isPlayingStream,
          initialData: false,
          builder: (context, isPlayingSnapshot) {
            final isPlaying = isPlayingSnapshot.data ?? false;

            return Material(
              color: kCardBlack.withOpacity(0.98),
              elevation: 12,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NowPlayingScreen(audioManager: audioManager),
                    ),
                  );
                },
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          song.imagePath ?? 'assets/images/visionlogo.jpg',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                color: kTextMain,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: kGoldBright,
                        ),
                        onPressed: () => audioManager.togglePlayPause(),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
