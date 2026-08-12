import 'package:flutter/material.dart';
import 'audio_manager.dart';

class ArtistProfileScreen extends StatelessWidget {
  final String artistName;
  final AudioManager audioManager;

  const ArtistProfileScreen({
    super.key,
    required this.artistName,
    required this.audioManager,
  });

  @override
  Widget build(BuildContext context) {
    final artistSongs = audioManager.tracks
        .where((s) => s.artist == artistName)
        .toList();

    final artistImage = artistSongs.isNotEmpty
        ? artistSongs.first.imagePath
        : null;

    // Generate a gradient based on artist name hash for visual consistency
    final colors = [
      [const Color(0xFFFB923C), const Color(0xFFF97316)], // Orange
      [const Color(0xFFC084FC), const Color(0xFFE879F9)], // Purple
      [const Color(0xFF38BDF8), const Color(0xFF3B82F6)], // Blue
      [const Color(0xFF2DD4BF), const Color(0xFF10B981)], // Teal
      [const Color(0xFFFB7185), const Color(0xFFF43F5E)], // Red
    ];
    final gradient = colors[artistName.hashCode % colors.length];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(artistName),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: artistImage != null
                    ? Image.asset(
                        artistImage,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.4),
                        colorBlendMode: BlendMode.darken,
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${artistSongs.length} Songs',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = artistSongs[index];
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: song.imagePath != null
                        ? Image.asset(song.imagePath!, fit: BoxFit.cover)
                        : const Icon(Icons.music_note, color: Colors.white70),
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                  onPressed: () => audioManager.playSong(song),
                ),
                onTap: () => audioManager.playSong(song),
              );
            }, childCount: artistSongs.length),
          ),
        ],
      ),
    );
  }
}
