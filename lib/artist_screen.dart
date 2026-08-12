import 'package:flutter/material.dart';

import 'audio_manager.dart';
import 'song.dart';
import 'vision_theme.dart';
import 'now_playing_screen.dart';
import 'core/services/media_source_resolver.dart';

class ArtistScreen extends StatelessWidget {
  final String artistName;
  final AudioManager audioManager;

  const ArtistScreen({
    super.key,
    required this.artistName,
    required this.audioManager,
  });

  Color? get kBackground => null;

  @override
  Widget build(BuildContext context) {
    final List<Song> songs = audioManager.tracks
        .where((s) => s.artist.toLowerCase() == artistName.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: kBackgroundDark,
      appBar: AppBar(
        backgroundColor: kBackgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextMain),
        title: Text(artistName, style: const TextStyle(color: kTextMain)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: songs.isEmpty
            ? const Center(
                child: Text(
                  'No songs for this artist yet.',
                  style: TextStyle(color: kTextSoft),
                ),
              )
            : ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: song.imagePath != null
                          ? Image(
                              image: MediaSourceResolver.artwork(
                                song.imagePath,
                              ),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              color: kBackground,
                              child: const Icon(Icons.music_note, color: kGold),
                            ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(
                        color: kTextMain,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(color: kTextSoft),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      await audioManager.playSong(song);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                NowPlayingScreen(audioManager: audioManager),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
