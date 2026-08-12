import 'package:flutter/material.dart';
import 'package:visionmusicapp/artist_screen.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/features/video/video_hub_screen.dart';
import 'package:visionmusicapp/now_playing_screen.dart';
import 'package:visionmusicapp/playlists_screen.dart';
import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/fade_route.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';
import 'package:visionmusicapp/core/services/media_source_resolver.dart';

class LibraryHubScreen extends StatelessWidget {
  final AudioManager audioManager;

  const LibraryHubScreen({super.key, required this.audioManager});

  List<String> _artists() {
    final names =
        audioManager.tracks.map((song) => song.artist).toSet().toList()..sort();
    return names;
  }

  List<String> _albums() {
    final names =
        audioManager.tracks
            .map((song) => song.albumTitle)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    return names;
  }

  @override
  Widget build(BuildContext context) {
    return VisionBackground(
      child: AnimatedBuilder(
        animation: audioManager,
        builder: (context, _) {
          final artists = _artists();
          final albums = _albums();
          final songs = audioManager.tracks;
          final favorites = audioManager.favoriteSongs;
          final recents = audioManager.recentSongs;

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text(
                'Library',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
              children: [
                _SectionCard(
                  title: 'Favorites',
                  subtitle: favorites.isEmpty
                      ? 'Tap the heart on any song to save it here.'
                      : '${favorites.length} favorite ${favorites.length == 1 ? 'song' : 'songs'}.',
                  children: favorites.isEmpty
                      ? [
                          _EmptyHint(
                            icon: Icons.favorite_outline_rounded,
                            text: 'Your favorites will appear here.',
                            actionLabel: 'Explore catalog',
                            onAction: () => _showSongListSheet(context, songs),
                          ),
                        ]
                      : favorites
                            .map(
                              (s) => _CompactSongTile(
                                song: s,
                                audioManager: audioManager,
                              ),
                            )
                            .toList(),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Recently Played',
                  subtitle: recents.isEmpty
                      ? "What you've been listening to will show up here."
                      : '${recents.length} recent ${recents.length == 1 ? 'track' : 'tracks'}.',
                  children: recents.isEmpty
                      ? const [
                          _EmptyHint(
                            icon: Icons.history_rounded,
                            text: 'Play a song to start your history.',
                          ),
                        ]
                      : recents
                            .take(10)
                            .map(
                              (s) => _CompactSongTile(
                                song: s,
                                audioManager: audioManager,
                              ),
                            )
                            .toList(),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Your Collection',
                  subtitle: 'Quick access to the core of Vision Music.',
                  children: [
                    _buildNavTile(
                      context,
                      title: 'Playlists',
                      subtitle: 'Create and organize your listening sets',
                      icon: Icons.queue_music_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlaylistsScreen(audioManager: audioManager),
                          ),
                        );
                      },
                    ),
                    _buildInfoTile(
                      title: 'Artists',
                      subtitle:
                          '${artists.length} artists available in this build',
                      icon: Icons.mic_rounded,
                      onTap: () => _openArtistList(context, artists),
                    ),
                    _buildInfoTile(
                      title: 'Albums',
                      subtitle:
                          '${albums.length} albums in the current catalog',
                      icon: Icons.album_rounded,
                      onTap: () => _showSimpleListSheet(
                        context,
                        title: 'Albums',
                        items: albums,
                        emptyMessage: 'No albums yet.',
                      ),
                    ),
                    _buildInfoTile(
                      title: 'Songs',
                      subtitle: '${songs.length} songs ready to play',
                      icon: Icons.music_note_rounded,
                      onTap: () => _showSongListSheet(context, songs),
                    ),
                    _buildNavTile(
                      context,
                      title: 'Videos',
                      subtitle: 'Music videos, podcasts, and more',
                      icon: Icons.video_library_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VideoHubScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _LeadingIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(color: kTextMain, fontSize: 17),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: kTextSoft, fontSize: 13),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: kTextSoft,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _LeadingIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(color: kTextMain, fontSize: 17),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: kTextSoft, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: kTextSoft),
      onTap: onTap,
    );
  }

  void _openArtistList(BuildContext context, List<String> artists) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kDarkCard,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Artists',
                style: TextStyle(
                  color: kTextMain,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: artists.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: Colors.white12),
                  itemBuilder: (context, index) {
                    final artist = artists[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        artist,
                        style: const TextStyle(color: kTextMain),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: kTextSoft,
                        size: 14,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtistScreen(
                              artistName: artist,
                              audioManager: audioManager,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimpleListSheet(
    BuildContext context, {
    required String title,
    required List<String> items,
    required String emptyMessage,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kDarkCard,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kTextMain,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Text(emptyMessage, style: const TextStyle(color: kTextSoft))
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: Colors.white12),
                    itemBuilder: (context, index) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        items[index],
                        style: const TextStyle(color: kTextMain),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSongListSheet(BuildContext context, List<Song> songs) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kDarkCard,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Songs',
                style: TextStyle(
                  color: kTextMain,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: songs.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: Colors.white12),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        song.title,
                        style: const TextStyle(color: kTextMain),
                      ),
                      subtitle: Text(
                        song.artist,
                        style: const TextStyle(color: kTextSoft),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSongTile extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;

  const _CompactSongTile({required this.song, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    final artwork = MediaSourceResolver.artwork(song.imagePath);
    final isFavorite = audioManager.isFavorite(song);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () async {
          await audioManager.playSong(song);
          if (context.mounted) {
            Navigator.push(
              context,
              fadeRoute(NowPlayingScreen(audioManager: audioManager)),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: artwork,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.white10,
                  child: const Icon(Icons.music_note, color: kVisionGoldLight),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kTextSoft, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: isFavorite ? kVisionGoldLight : Colors.white54,
                size: 20,
              ),
              onPressed: () => audioManager.toggleFavorite(song),
              tooltip: isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // The card paints itself with `Ink`, not a plain `Container` decoration.
    //
    // Flutter was warning "ListTile background color or ink splashes may be
    // invisible" at launch — twelve times, because MainShell's IndexedStack
    // pre-builds every tab. A ListTile draws its ripple onto the nearest
    // Material; a decorated Container paints *over* that Material, so the
    // splash renders underneath the card and is never seen. Tapping a library
    // row therefore gave no touch feedback at all.
    //
    // `Material` + `Ink` puts the decoration into the Material's own paint
    // pass, so ripples land on top where they belong.
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(kRadiusL),
      child: Ink(
        padding: const EdgeInsets.all(kSpaceM),
        decoration: BoxDecoration(
          color: kDarkCard.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(kRadiusL),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: kTextMain,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: kTextSoft, fontSize: 13),
            ),
            const SizedBox(height: kSpaceS),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;

  const _LeadingIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: kVisionGoldLight),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyHint({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white38, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: kTextSoft, fontSize: 13),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.explore_outlined, size: 17),
              label: Text(actionLabel!),
              style: OutlinedButton.styleFrom(
                foregroundColor: kVisionGoldLight,
                side: BorderSide(color: kVisionGold.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
