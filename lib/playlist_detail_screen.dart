import 'package:flutter/material.dart';
import 'package:visionmusicapp/controllers/playlist_controller.dart';
import 'package:visionmusicapp/models/playlist.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/song_row.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  final PlaylistController controller;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.controller,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        // Re-fetch playlist from controller to get the latest version
        final currentPlaylist = widget.controller.playlists.firstWhere(
          (p) => p.id == widget.playlist.id,
          orElse: () => widget.playlist, // Fallback, though should not happen
        );

        final songs = widget.controller.songsForPlaylist(currentPlaylist);

        return Scaffold(
          backgroundColor: kDarkBackground,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: kTextMain,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(currentPlaylist.name),
          ),
          body: songs.isEmpty
              ? const Center(
                  child: Text(
                    'This playlist is empty.\nAdd songs from the 3-dot menu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextSoft),
                  ),
                )
              : ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return SongRow(
                      song: song,
                      audioManager: widget.controller.audioManager,
                    );
                  },
                ),
        );
      },
    );
  }
}
