import 'package:flutter/material.dart';

import 'audio_manager.dart';
import 'song.dart';
import 'vision_theme.dart';
import 'now_playing_screen.dart';

class QueueScreen extends StatelessWidget {
  final AudioManager audioManager;

  const QueueScreen({super.key, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: audioManager,
      builder: (context, _) {
        final Song? current = audioManager.currentSong;
        final List<Song> tracks = audioManager.tracks;

        int currentIndex = -1;
        if (current != null) {
          currentIndex = tracks.indexOf(current);
        }

        final List<Song> upNext =
            currentIndex == -1 || currentIndex + 1 >= tracks.length
            ? const <Song>[]
            : tracks.sublist(currentIndex + 1);

        return Scaffold(
          backgroundColor: kBackgroundDark,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Up Next',
                    style: TextStyle(
                      color: kTextMain,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Current song and upcoming tracks in your queue',
                    style: TextStyle(color: kTextSoft, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Now playing card
                  if (current != null) ...[
                    _NowPlayingCard(song: current, audioManager: audioManager),
                    const SizedBox(height: 20),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kDarkCard,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.music_note, color: kGold, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No song is currently playing',
                              style: TextStyle(color: kTextSoft, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Text(
                    'Playing Next',
                    style: const TextStyle(
                      color: kTextMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Up next list
                  if (upNext.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Nothing in your queue yet.\nUse “Add to Queue” or “Play Next” from the 3-dot menu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kTextSoft, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: upNext.length,
                        itemBuilder: (context, index) {
                          final song = upNext[index];
                          return _QueueSongRow(
                            song: song,
                            audioManager: audioManager,
                          );
                        },
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

class _NowPlayingCard extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;

  const _NowPlayingCard({required this.song, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: song.imagePath != null
                ? Image.asset(
                    song.imagePath!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: kBackgroundDark,
                    child: const Icon(Icons.music_note, color: kGold, size: 28),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    color: kTextMain,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: const TextStyle(color: kTextSoft, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Now playing',
                  style: TextStyle(
                    color: kGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NowPlayingScreen(audioManager: audioManager),
                ),
              );
            },
            child: Container(
              height: 32,
              width: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kGold,
              ),
              child: const Icon(
                Icons.open_in_full,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueSongRow extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;

  const _QueueSongRow({required this.song, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kDarkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Artwork
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: song.imagePath != null
                ? Image.asset(
                    song.imagePath!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 44,
                    height: 44,
                    color: kBackgroundDark,
                    child: const Icon(Icons.music_note, color: kGold, size: 24),
                  ),
          ),
          const SizedBox(width: 10),

          // Title / artist
          Expanded(
            child: GestureDetector(
              onTap: () => audioManager.playSong(song),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: kTextMain,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: const TextStyle(color: kTextSoft, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Remove from queue
          IconButton(
            icon: const Icon(Icons.close, color: kTextSoft, size: 18),
            onPressed: () => audioManager.removeFromQueue(song),
          ),
        ],
      ),
    );
  }
}
