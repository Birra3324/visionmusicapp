import 'package:flutter/material.dart';
import 'package:visionmusicapp/widgets/mini_player.dart';
import 'vision_theme.dart';
import 'audio_manager.dart';
import 'song.dart';
import 'now_playing_screen.dart';
import 'settings_manager.dart';
import 'widgets/fade_route.dart';

class SearchScreen extends StatefulWidget {
  final AudioManager audioManager;
  final SettingsManager settings;
  const SearchScreen({
    super.key,
    required this.audioManager,
    required this.settings,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final audioManager = widget.audioManager;
    final allSongs = audioManager.tracks;

    final results = _query.isEmpty
        ? []
        : allSongs
              .where(
                (s) =>
                    s.title.toLowerCase().contains(_query.toLowerCase()) ||
                    s.artist.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return Container(
      color: kDarkBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search',
                style: TextStyle(
                  color: kTextMain,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Find songs, artists and more',
                style: TextStyle(color: kTextSoft, fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 32),
              Expanded(
                child: _query.isEmpty
                    ? const Center(
                        child: Text(
                          'Type something to search...',
                          style: TextStyle(color: kTextSoft, fontSize: 14),
                        ),
                      )
                    : results.isEmpty
                    ? const Center(
                        child: Text(
                          'No matches found.',
                          style: TextStyle(color: kTextSoft),
                        ),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final song = results[index];
                          return _SearchResultRow(
                            song: song,
                            audioManager: audioManager,
                          );
                        },
                      ),
              ),
              MiniPlayer(audioManager: audioManager),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: kDarkCard.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: kTextSoft, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(color: kTextMain, fontSize: 14),
              cursorColor: kVisionGoldLight,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search your music',
                hintStyle: TextStyle(color: kTextSoft, fontSize: 14),
              ),
              onChanged: (value) {
                setState(() => _query = value.trim());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;

  const _SearchResultRow({required this.song, required this.audioManager});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await audioManager.playSong(song);
        if (context.mounted) {
          Navigator.push(
            context,
            fadeRoute(NowPlayingScreen(audioManager: audioManager)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kDarkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: song.imagePath != null
                  ? Image.asset(
                      song.imagePath!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 44,
                      width: 44,
                      color: kDarkBackground,
                      child: const Icon(
                        Icons.music_note,
                        color: kVisionGoldLight,
                        size: 24,
                      ),
                    ),
            ),
            const SizedBox(width: 10),

            // Song Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: kTextMain,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: const TextStyle(color: kTextSoft, fontSize: 12),
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // Play Button
            Container(
              height: 30,
              width: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kVisionGoldLight,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.black,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
