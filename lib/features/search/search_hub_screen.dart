import 'package:flutter/material.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/now_playing_screen.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/fade_route.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';
import 'package:visionmusicapp/core/services/media_source_resolver.dart';
import 'package:visionmusicapp/core/services/app_observability.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import '../recognition/presentation/screens/music_identification_screen.dart';

class SearchHubScreen extends StatefulWidget {
  final AudioManager audioManager;
  final SettingsManager settings;

  const SearchHubScreen({
    super.key,
    required this.audioManager,
    required this.settings,
  });

  @override
  State<SearchHubScreen> createState() => _SearchHubScreenState();
}

class _SearchHubScreenState extends State<SearchHubScreen> {
  String _query = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final audioManager = widget.audioManager;
    final allSongs = audioManager.tracks;
    final results = _query.isEmpty
        ? <Song>[]
        : allSongs.where((song) {
            final q = _query.toLowerCase();
            return song.title.toLowerCase().contains(q) ||
                song.artist.toLowerCase().contains(q) ||
                (song.albumTitle?.toLowerCase().contains(q) ?? false);
          }).toList();

    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.search,
                  style: const TextStyle(
                    color: kTextMain,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.searchDescription,
                  style: const TextStyle(
                    color: kTextSoft,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                _buildSearchBar(),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SearchHintChip(
                      label: 'Ali Birra',
                      onTap: () => _setQuery('Ali Birra'),
                    ),
                    _SearchHintChip(
                      label: 'Shukri Jamal',
                      onTap: () => _setQuery('Shukri Jamal'),
                    ),
                    _SearchHintChip(
                      label: 'Oromo Music',
                      onTap: () => _setQuery('Oromo'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildResults(results, l10n)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(List<Song> results, AppLocalizations l10n) {
    if (_query.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kDarkCard.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.manage_search_rounded,
              color: kVisionGoldLight,
              size: 34,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.searchQuestion,
              style: const TextStyle(
                color: kTextMain,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.searchInstructions,
              style: const TextStyle(
                color: kTextSoft,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Text(l10n.noMatches, style: const TextStyle(color: kTextSoft)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return _SearchResultRow(song: song, audioManager: widget.audioManager);
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(kRadiusL),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: kSpaceM),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: kTextSoft, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: kStyleBody,
              cursorColor: kVisionGold,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: AppLocalizations.of(context)!.searchHint,
                hintStyle: kStyleCaption.copyWith(fontSize: 14),
              ),
              onChanged: (value) {
                setState(() => _query = value.trim());
              },
              onSubmitted: (value) {
                final normalized = value.trim().toLowerCase();
                final hasResults =
                    normalized.isNotEmpty &&
                    widget.audioManager.tracks.any(
                      (song) =>
                          song.title.toLowerCase().contains(normalized) ||
                          song.artist.toLowerCase().contains(normalized) ||
                          (song.albumTitle?.toLowerCase().contains(
                                normalized,
                              ) ??
                              false),
                    );
                AppObservability.instance.search(hasResults: hasResults);
              },
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                setState(() => _query = '');
              },
              child: const Icon(
                Icons.close_rounded,
                color: kTextSoft,
                size: 18,
              ),
            )
          else
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  fadeRoute(const MusicIdentificationScreen()),
                );
              },
              icon: const Icon(Icons.mic_rounded, color: kVisionGold, size: 22),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
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
        try {
          await AppObservability.instance.searchResultSelected(song.id);
          await audioManager.playSong(song);
          if (context.mounted) {
            Navigator.push(
              context,
              fadeRoute(NowPlayingScreen(audioManager: audioManager)),
            );
          }
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This song could not be played.')),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kDarkCard.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: song.imagePath != null
                  ? Image(
                      image: MediaSourceResolver.artwork(song.imagePath),
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
                    '${song.artist}${song.albumTitle != null ? ' • ${song.albumTitle}' : ''}',
                    style: const TextStyle(color: kTextSoft, fontSize: 12),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
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

class _SearchHintChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchHintChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: kVisionGold.withValues(alpha: 0.1),
      side: BorderSide(color: kVisionGold.withValues(alpha: 0.25), width: 0.8),
      labelStyle: kStyleLabel.copyWith(color: kVisionGoldLight, fontSize: 12),
      shape: const StadiumBorder(),
    );
  }
}
