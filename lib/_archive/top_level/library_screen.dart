import 'package:flutter/material.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/playlists_screen.dart';

class LibraryScreen extends StatelessWidget {
  final AudioManager audioManager;

  const LibraryScreen({super.key, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Library',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: kVisionGoldLight),
              onSelected: (value) {
                /* Handle edit actions */
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: ListView(
          children: [
            _buildLibraryItem(
              context,
              'Playlists',
              Icons.music_note_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistsScreen(audioManager: audioManager),
                  ),
                );
              },
            ),
            _buildLibraryItem(context, 'Artists', Icons.mic_rounded, () {
              // TODO: Navigate to ArtistsScreen
            }),
            _buildLibraryItem(context, 'Albums', Icons.album_rounded, () {
              // TODO: Navigate to AlbumsScreen
            }),
            _buildLibraryItem(context, 'Songs', Icons.music_video_rounded, () {
              // TODO: Navigate to SongsScreen
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: kVisionGoldLight, size: 28),
      title: Text(
        title,
        style: const TextStyle(color: kTextMain, fontSize: 18),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: kTextSoft,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
