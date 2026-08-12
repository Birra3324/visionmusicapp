import 'package:flutter/material.dart';
import '../audio_manager.dart';
import '../song.dart';
import '../vision_theme.dart';
import '../now_playing_screen.dart';
import '../artist_screen.dart';
import 'fade_route.dart';

class SongListTile extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;
  final VoidCallback? onPlay;
  final VoidCallback? onShowOptions;

  const SongListTile({
    super.key,
    required this.song,
    required this.audioManager,
    this.onPlay,
    this.onShowOptions,
  });

  Color? get kBackground => null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Hero(
          tag: 'artwork-${song.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: song.imagePath != null
                ? Image.asset(
                    song.imagePath!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.music_note, color: kTextSoft),
          ),
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kTextMain, fontWeight: FontWeight.w500),
        ),
        subtitle: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              fadeRoute(
                ArtistScreen(
                  artistName: song.artist,
                  audioManager: audioManager,
                ),
              ),
            );
          },
          child: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kTextSoft,
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        onTap: () {
          if (onPlay != null) {
            onPlay!();
          } else {
            audioManager.playSong(song);
            Navigator.push(
              context,
              fadeRoute(NowPlayingScreen(audioManager: audioManager)),
            );
          }
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onShowOptions != null)
              IconButton(
                icon: const Icon(Icons.more_vert, color: kTextSoft),
                onPressed: onShowOptions,
              ),
            GestureDetector(
              onTap: () {
                if (onPlay != null) {
                  onPlay!();
                } else {
                  audioManager.playSong(song);
                  Navigator.push(
                    context,
                    fadeRoute(NowPlayingScreen(audioManager: audioManager)),
                  );
                }
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGold,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
