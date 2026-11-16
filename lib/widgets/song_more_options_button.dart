import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'open_song_video.dart';
import 'playlist_name_dialog.dart';
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
  final Future<void> Function()? onRemoveFromPlaylist;

  const SongMoreOptionsButton({
    super.key,
    required this.song,
    required this.audioManager,
    this.iconSize = 22,
    this.iconColor,
    this.onRemoveFromPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final isSaved = audioManager.isSaved(song);
    final isFavorite = audioManager.isFavorite(song);

    return PopupMenuButton<String>(
      tooltip: 'More options for ${song.title}',
      iconSize: iconSize,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert_rounded, color: iconColor ?? kTextSoft),
      onSelected: (value) async {
        switch (value) {
          case 'remove_playlist':
            await onRemoveFromPlaylist?.call();
            break;
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
            await _showAddToPlaylistDialog(context, song);
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
            await openSongVideo(context, song, audioManager);
            break;
        }
      },
      itemBuilder: (context) => [
        if (onRemoveFromPlaylist != null)
          const PopupMenuItem(
            value: 'remove_playlist',
            child: Text('Remove from Playlist'),
          ),
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
        const PopupMenuItem(value: 'share', child: Text('Share')),
        if (song.youtubeUrl != null)
          const PopupMenuItem(
            value: 'youtube',
            child: Text('Watch on YouTube'),
          ),
      ],
    );
  }

  Future<void> _showAddToPlaylistDialog(BuildContext context, Song song) async {
    final controller = PlaylistController(audioManager: audioManager);
    try {
      await controller.load();
      if (!context.mounted) return;
      final selection = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add to Playlist'),
          content: SizedBox(
            width: 360,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final playlist in controller.playlists)
                  ListTile(
                    title: Text(playlist.name),
                    onTap: () => Navigator.pop(dialogContext, playlist.id),
                  ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Playlist'),
                  onTap: () => Navigator.pop(dialogContext, '__new__'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      if (!context.mounted || selection == null) return;
      if (selection == '__new__') {
        // Use the still-mounted song screen, never a dismissed dialog context.
        final name = await showPlaylistNameDialog(context);
        if (!context.mounted || name == null) return;
        final playlist = await controller.createPlaylist(name);
        await controller.addSongToPlaylist(playlist, song);
      } else {
        final playlist = controller.playlists.firstWhere(
          (p) => p.id == selection,
        );
        await controller.addSongToPlaylist(playlist, song);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to playlist.')));
      }
    } finally {
      controller.dispose();
    }
  }
}
