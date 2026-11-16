import 'package:visionmusicapp/l10n/listener_strings.dart';
import 'package:flutter/material.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/controllers/playlist_controller.dart';
import 'package:visionmusicapp/playlist_detail_screen.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'widgets/playlist_name_dialog.dart';
import 'models/playlist.dart';

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

  Future<void> _createNewPlaylist() async {
    final name = await showPlaylistNameDialog(context);
    if (!mounted || name == null) return;
    await _controller.createPlaylist(name);
  }

  Future<void> _managePlaylist(Playlist playlist, String action) async {
    if (action == 'rename') {
      final name = await showPlaylistNameDialog(
        context,
        initialName: playlist.name,
      );
      if (!mounted || name == null) return;
      await _controller.renamePlaylist(playlist.id, name);
    } else if (action == 'delete') {
      final remove = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.deletePlaylistTitle),
          content: Text(context.l10n.deletePlaylistMessage(playlist.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.delete),
            ),
          ],
        ),
      );
      if (!mounted || remove != true) return;
      await _controller.deletePlaylist(playlist.id);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(context.l10n.playlists, style: TextStyle(color: kTextMain)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.createPlaylist,
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
                  Text(
                    context.l10n.noPlaylists,
                    style: TextStyle(color: kTextMain, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _createNewPlaylist,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kVisionGold,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(context.l10n.createPlaylist),
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
                  context.l10n.songCount(
                    _controller.songsForPlaylist(playlist).length,
                  ),
                  style: const TextStyle(color: kTextSoft),
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: context.l10n.managePlaylist(playlist.name),
                  onSelected: (action) => _managePlaylist(playlist, action),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text(context.l10n.rename),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(context.l10n.delete),
                    ),
                  ],
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(
                        playlist: playlist,
                        controller: _controller,
                      ),
                    ),
                  );
                  if (mounted) await _controller.load();
                },
              );
            },
          );
        },
      ),
    );
  }
}
