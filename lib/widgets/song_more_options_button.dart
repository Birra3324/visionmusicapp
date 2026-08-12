import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../audio_manager.dart';
import '../song.dart';
import '../vision_theme.dart';
import '../controllers/playlist_controller.dart';
import '../core/services/app_observability.dart';

class SongMoreOptionsButton extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;
  final double iconSize;
  final Color? iconColor;

  const SongMoreOptionsButton({
    super.key,
    required this.song,
    required this.audioManager,
    this.iconSize = 22,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSaved = audioManager.isSaved(song);
    final isFavorite = audioManager.isFavorite(song);

    return PopupMenuButton<String>(
      iconSize: iconSize,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert_rounded, color: iconColor ?? kTextSoft),
      onSelected: (value) async {
        switch (value) {
          case 'add_queue':
            audioManager.addToQueue(song);
            break;
          case 'toggle_save':
            audioManager.toggleSave(song);
            break;
          case 'toggle_favorite':
            audioManager.toggleFavorite(song);
            break;
          case 'add_to_playlist':
            unawaited(AppObservability.instance.playlistAdd(song.id));
            _showAddToPlaylistDialog(context, song);
            break;
          case 'download':
            await audioManager.download(song);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved for offline access.')),
              );
            }
            break;
          case 'share':
            final shareText =
                song.youtubeUrl ??
                '${song.title} — ${song.artist} on Vision Music';
            await Clipboard.setData(ClipboardData(text: shareText));
            await AppObservability.instance.share(song.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share text copied.')),
              );
            }
            break;
          case 'youtube':
            if (song.youtubeUrl != null) {
              final uri = Uri.parse(song.youtubeUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'add_queue', child: Text('Add to Queue')),
        PopupMenuItem(
          value: 'toggle_save',
          child: Text(isSaved ? 'Remove from Library' : 'Add to Library'),
        ),
        PopupMenuItem(
          value: 'toggle_favorite',
          child: Text(
            isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
          ),
        ),
        const PopupMenuItem(
          value: 'add_to_playlist',
          child: Text('Add to Playlist'),
        ),
        const PopupMenuItem(value: 'download', child: Text('Download')),
        const PopupMenuItem(value: 'share', child: Text('Share')),
        if (song.youtubeUrl != null)
          const PopupMenuItem(
            value: 'youtube',
            child: Text('Watch on YouTube'),
          ),
      ],
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    final playlistController = PlaylistController(audioManager: audioManager);
    playlistController.load();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kDarkCard,
          title: const Text('Add to Playlist'),
          content: AnimatedBuilder(
            animation: playlistController,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...playlistController.playlists.map(
                    (playlist) => ListTile(
                      title: Text(playlist.name),
                      onTap: () {
                        playlistController.addSongToPlaylist(playlist, song);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add, color: kVisionGoldLight),
                    title: const Text('New Playlist'),
                    onTap: () async {
                      Navigator.pop(context);
                      final newPlaylistName = await _showCreatePlaylistDialog(
                        context,
                      );
                      if (newPlaylistName != null &&
                          newPlaylistName.isNotEmpty) {
                        await playlistController.createPlaylist(
                          newPlaylistName,
                        );
                        final newPlaylist = playlistController.playlists.last;
                        await playlistController.addSongToPlaylist(
                          newPlaylist,
                          song,
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<String?> _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkCard,
        title: const Text('New Playlist'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
