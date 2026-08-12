import 'package:flutter/material.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/controllers/playlist_controller.dart';
import 'package:visionmusicapp/models/playlist.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/song_row.dart';

class PlaylistScreen extends StatefulWidget {
  final AudioManager audioManager;
  final Playlist playlist;

  const PlaylistScreen({
    super.key,
    required this.audioManager,
    required this.playlist,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late final PlaylistController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlaylistController(audioManager: widget.audioManager);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentPlaylist = _controller.playlists.firstWhere(
          (p) => p.id == widget.playlist.id,
          orElse: () => widget.playlist,
        );
        final songs = _controller.songsForPlaylist(currentPlaylist);

        return Scaffold(
          backgroundColor: kDarkBackground,
          appBar: AppBar(
            title: Text(
              currentPlaylist.name,
              style: const TextStyle(color: kTextMain),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: kTextMain),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return SongRow(
                      song: song,
                      audioManager: widget.audioManager,
                    );
                  },
                ),
        );
      },
    );
  }
}
