import 'package:flutter/material.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/controllers/playlist_controller.dart';
import 'package:visionmusicapp/playlist_detail_screen.dart';
import 'package:visionmusicapp/vision_theme.dart';

class PlaylistsScreen extends StatefulWidget {
  final AudioManager audioManager;

  const PlaylistsScreen({super.key, required this.audioManager});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  late final PlaylistController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlaylistController(audioManager: widget.audioManager);
    _controller.load();
  }

  void _createNewPlaylist() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: kDarkCard,
          title: const Text('New Playlist', style: TextStyle(color: kTextMain)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: kTextMain),
            decoration: const InputDecoration(
              hintText: 'Playlist Name',
              hintStyle: TextStyle(color: kTextSoft),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kTextSoft),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kVisionGold),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: kTextSoft)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Create', style: TextStyle(color: kVisionGold)),
            ),
          ],
        );
      },
    );

    if (name != null && name.isNotEmpty) {
      await _controller.createPlaylist(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: const Text('Playlists', style: TextStyle(color: kTextMain)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kVisionGold),
            onPressed: _createNewPlaylist,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final playlists = _controller.playlists;
          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.queue_music_rounded,
                    size: 64,
                    color: kTextSoft,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Playlists',
                    style: TextStyle(color: kTextMain, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _createNewPlaylist,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kVisionGold,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Create Playlist'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kDarkCard,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note, color: kTextSoft),
                ),
                title: Text(
                  playlist.name,
                  style: const TextStyle(color: kTextMain),
                ),
                subtitle: Text(
                  '${playlist.trackIndices.length} songs',
                  style: const TextStyle(color: kTextSoft),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(
                        playlist: playlist,
                        controller: _controller,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
