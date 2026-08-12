import 'package:flutter/material.dart';
import 'package:visionmusicapp/now_playing_screen.dart';
import 'vision_theme.dart';
import 'audio_manager.dart';
import 'song.dart';

class HomeScreen extends StatelessWidget {
  final AudioManager audioManager;
  const HomeScreen({super.key, required this.audioManager});

  Color? get kBgBlack => null;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: kBgBlack,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: audioManager,
            builder: (context, _) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Discover',
                        style: TextStyle(
                          color: kGoldBright,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Bright, colorful sounds from Vision Studio.',
                        style: TextStyle(color: kTextSoft, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Featured'),
                      const SizedBox(height: 12),
                      _featuredRow(context),

                      const SizedBox(height: 24),
                      _sectionTitle('Recently Played'),
                      const SizedBox(height: 12),
                      _recentlyPlayedRow(context),

                      const SizedBox(height: 24),
                      _sectionTitle('All Songs'),
                      const SizedBox(height: 12),
                      _allSongsList(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: kGoldBright,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _featuredRow(BuildContext context) {
    final featuredTracks = audioManager.tracks.take(3).toList();
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featuredTracks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final song = featuredTracks[index];
          return GestureDetector(
            onTap: () async {
              await audioManager.playSong(song);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NowPlayingScreen(audioManager: audioManager),
                ),
              );
            },
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                color: kCardBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: song.imagePath != null
                          ? Image.asset(
                              song.imagePath!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.white10,
                              child: const Icon(
                                Icons.music_note,
                                color: kTextSoft,
                                size: 48,
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            color: kTextSoft,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _recentlyPlayedRow(BuildContext context) {
    final recentSongs = audioManager.recentSongs;
    if (recentSongs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recentSongs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final song = recentSongs[index];
          return GestureDetector(
            onTap: () async {
              await audioManager.playSong(song);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NowPlayingScreen(audioManager: audioManager),
                ),
              );
            },
            child: SizedBox(
              width: 120,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: song.imagePath != null
                          ? Image.asset(
                              song.imagePath!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: kCardBlack,
                              child: const Icon(
                                Icons.music_note,
                                color: kTextSoft,
                                size: 48,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextMain,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _allSongsList(BuildContext context) {
    final tracks = audioManager.tracks;
    final current = audioManager.currentSong;

    return Column(
      children: tracks.map((song) {
        final isCurrent = song.id == current?.id;
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isCurrent ? kGoldBright.withOpacity(0.3) : kCardBlack,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: song.imagePath != null
                  ? Image.asset(
                      song.imagePath!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: Colors.white10,
                      child: Icon(
                        isCurrent ? Icons.equalizer_rounded : Icons.music_note,
                        color: isCurrent ? kGoldBright : kTextSoft,
                      ),
                    ),
            ),
            title: Text(song.title, style: const TextStyle(color: kTextMain)),
            subtitle: Text(
              song.artist,
              style: const TextStyle(color: kTextSoft),
            ),
            onTap: () async {
              await audioManager.playSong(song);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NowPlayingScreen(audioManager: audioManager),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
