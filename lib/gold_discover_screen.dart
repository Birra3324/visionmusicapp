import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';
import 'vision_theme.dart';
import 'audio_manager.dart';
import 'song.dart';
import 'now_playing_screen.dart';
import 'widgets/song_row.dart';
import 'widgets/fade_route.dart';
import 'core/services/media_source_resolver.dart';

// Used to switch to the Watch tab from the home screen
typedef OnSwitchTab = void Function(int index);

class GoldDiscoverScreen extends StatefulWidget {
  final AudioManager audioManager;
  final OnSwitchTab? onSwitchTab;

  const GoldDiscoverScreen({
    super.key,
    required this.audioManager,
    this.onSwitchTab,
  });

  @override
  State<GoldDiscoverScreen> createState() => _GoldDiscoverScreenState();
}

class _GoldDiscoverScreenState extends State<GoldDiscoverScreen> {
  int _selectedTabIndex = 0;
  static const List<String> _tabs = ['Recent', 'Popular', 'New', 'Trending'];

  /// First name of the signed-in user, falling back to a neutral greeting
  /// rather than showing an empty space or a raw email address.
  String _firstName() {
    final user = FirebaseAuth.instance.currentUser;
    final display = user?.displayName?.trim();
    if (display != null && display.isNotEmpty) return display.split(' ').first;
    final email = user?.email;
    if (email != null && email.isNotEmpty) {
      final local = email.split('@').first;
      if (local.isNotEmpty) {
        return local[0].toUpperCase() + local.substring(1);
      }
    }
    return 'there';
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 22) return 'Good evening';
    return 'Good night';
  }

  /// Each tab is a real view over the catalogue rather than the same list four
  /// times. Recently Played comes from playback history; the rest are derived
  /// deterministically so the ordering is stable between rebuilds.
  List<Song> _songsForTab(int index) {
    final all = widget.audioManager.tracks;
    switch (index) {
      case 0: // Recently Played — real history, newest first
        final recent = widget.audioManager.recentSongs;
        return recent.isEmpty ? all : recent;
      case 1: // Popular — longest tracks stand in for play counts until we have them
        final popular = [...all]
          ..sort((a, b) => b.duration.compareTo(a.duration));
        return popular;
      case 2: // New Releases — reverse catalogue order, newest additions last
        return all.reversed.toList();
      case 3: // Trending — alphabetical, a stable stand-in for real signals
      default:
        final trending = [...all]..sort((a, b) => a.title.compareTo(b.title));
        return trending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = widget.audioManager;

    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    kSpaceM,
                    kSpaceL,
                    kSpaceM,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_greeting()}, ${_firstName()} 👋',
                                  style: kStyleCaption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                // "Vision" white, "Music" gold — the brand
                                // reads as one wordmark rather than a title.
                                const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: 'Vision '),
                                      TextSpan(
                                        text: 'Music',
                                        style: TextStyle(color: kVisionGold),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: kTextMain,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Logo badge
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: kVisionGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(kRadiusS),
                              border: Border.all(
                                color: kVisionGold.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(kRadiusS - 1),
                              child: Image.asset(
                                'assets/images/visionlogo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kSpaceM),

                      // Tapping jumps to the Search tab, which holds the real
                      // search implementation. Previously this was inert.
                      _SearchBar(onTap: () => widget.onSwitchTab?.call(3)),

                      const SizedBox(height: kSpaceL),
                    ],
                  ),
                ),
              ),
            ),

            // ── Listen / Watch entry cards ────────────────────────────────
            SliverToBoxAdapter(
              child: _ListenWatchSection(
                onWatchTap: () => widget.onSwitchTab?.call(1),
                onListenTap: () => widget.onSwitchTab?.call(2),
              ),
            ),

            // ── Trending horizontal scroll ─────────────────────────────────
            SliverToBoxAdapter(
              child: _TrendingSection(
                audioManager: audioManager,
                onSeeAll: () => widget.onSwitchTab?.call(2),
              ),
            ),

            // ── Pinned tab bar ─────────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabsHeaderDelegate(
                tabs: _tabs,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (i) => setState(() => _selectedTabIndex = i),
              ),
            ),

            // ── Song list ─────────────────────────────────────────────────
            SliverPadding(
              // Clear the mini-player. It only occupies space when audio is
              // loaded, so the padding tracks that rather than reserving a
              // permanent gap that looks like a layout mistake when idle.
              padding: EdgeInsets.fromLTRB(
                kSpaceM,
                kSpaceXS,
                kSpaceM,
                audioManager.currentSong != null ? 96.0 : kSpaceXL,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final songs = _songsForTab(_selectedTabIndex);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: kSpaceXS),
                    child: SongRow(
                      song: songs[index],
                      audioManager: audioManager,
                    ),
                  );
                }, childCount: _songsForTab(_selectedTabIndex).length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Listen / Watch entry section ────────────────────────────────────────────

class _ListenWatchSection extends StatelessWidget {
  final VoidCallback? onWatchTap;
  final VoidCallback? onListenTap;

  const _ListenWatchSection({this.onWatchTap, this.onListenTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpaceM, 0, kSpaceM, kSpaceXL),
      child: Row(
        children: [
          // Listen card
          Expanded(
            child: _EntryCard(
              icon: Icons.headphones_rounded,
              label: 'Listen',
              subtitle: 'Music',
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A1C09), Color(0xFF4A3310)],
              ),
              accentColor: kVisionGold,
              // Goes to Library — the music destination. Previously null,
              // which left the card looking disabled and doing nothing.
              onTap: onListenTap,
            ),
          ),
          const SizedBox(width: kSpaceS),
          // Watch card
          Expanded(
            child: _EntryCard(
              icon: Icons.play_circle_rounded,
              label: 'Watch',
              subtitle: 'Videos',
              // Burgundy, not blue. Video is the other half of Vision Music,
              // so it needs to sit in the same warm family as the gold rather
              // than reading as a separate product.
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A0E10), kVisionRedDeep],
              ),
              accentColor: kVisionRed,
              onTap: onWatchTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final Color accentColor;
  final VoidCallback? onTap;

  const _EntryCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.72 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(kRadiusL),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(kSpaceM),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(kRadiusS),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: kSpaceS),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: kTextSoft, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: accentColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search entry point ───────────────────────────────────────────────────────
//
// Deliberately not a TextField. Typing here and typing on the Search tab would
// be two input states for one query, which is how search boxes drift out of
// sync. This is a button that hands off to the real search screen.

class _SearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const _SearchBar({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: kCardBlack,
          borderRadius: BorderRadius.circular(kRadiusM),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: kSpaceM),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: kTextSoft, size: 20),
            SizedBox(width: kSpaceS),
            Expanded(
              child: Text(
                'Search songs, artists, albums...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: kTextDim, fontSize: 14),
              ),
            ),
            Icon(Icons.tune_rounded, color: kTextSoft, size: 19),
          ],
        ),
      ),
    );
  }
}

// ─── Trending section ─────────────────────────────────────────────────────────

class _TrendingSection extends StatelessWidget {
  final AudioManager audioManager;
  final VoidCallback? onSeeAll;
  const _TrendingSection({required this.audioManager, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final songs = audioManager.tracks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(kSpaceM, 0, kSpaceM, kSpaceS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Now',
                style: kStyleHeadline.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpaceXXS,
                    vertical: kSpaceXXS,
                  ),
                  child: Text(
                    'See all',
                    style: kStyleCaption.copyWith(
                      color: kVisionGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) {
            // Three cards across with the gutters accounted for, so the row
            // always lands on a whole card rather than clipping one mid-way.
            final width = MediaQuery.sizeOf(context).width;
            final cardWidth = ((width - (kSpaceM * 2) - (kSpaceS * 2)) / 3)
                .clamp(120.0, 190.0);
            return SizedBox(
              height: cardWidth * 1.28,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: kSpaceM),
                itemCount: songs.length.clamp(0, 10),
                itemBuilder: (context, index) => _TrendingCard(
                  song: songs[index],
                  audioManager: audioManager,
                  width: cardWidth,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: kSpaceL),
      ],
    );
  }
}

// ─── Trending card ────────────────────────────────────────────────────────────

class _TrendingCard extends StatelessWidget {
  final Song song;
  final AudioManager audioManager;
  final double width;

  const _TrendingCard({
    required this.song,
    required this.audioManager,
    required this.width,
  });

  void _openNowPlaying(BuildContext context) async {
    await audioManager.playSong(song);
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).push(fadeRoute(NowPlayingScreen(audioManager: audioManager)));
  }

  @override
  Widget build(BuildContext context) {
    final art = MediaSourceResolver.artwork(song.imagePath);
    return GestureDetector(
      onTap: () => _openNowPlaying(context),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: kSpaceS),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusL),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Artwork
              Hero(
                tag: 'artwork_${song.id}',
                child: Image(
                  image: ResizeImage.resizeIfNeeded(
                    (width * 3).round(),
                    null,
                    art,
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: kCardBlack,
                    child: const Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        color: kVisionGoldDim,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.30, 0.62, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.90),
                    ],
                  ),
                ),
              ),
              // Text + play button
              Positioned(
                left: kSpaceS,
                right: kSpaceS,
                bottom: kSpaceS,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kVisionGold,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pinned tabs header ───────────────────────────────────────────────────────

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  _TabsHeaderDelegate({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: kAppBackground.withValues(alpha: 0.96),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(kSpaceM, 0, kSpaceL, 0),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = i == selectedIndex;
            return GestureDetector(
              onTap: () => onTabSelected(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: kSpaceXS),
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpaceS + 2,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? kVisionGold.withValues(alpha: 0.13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(kRadiusS),
                  border: Border.all(
                    color: selected
                        ? kVisionGold.withValues(alpha: 0.35)
                        : Colors.transparent,
                    width: 0.7,
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: selected ? kVisionGoldLight : kTextSoft,
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate old) =>
      old.selectedIndex != selectedIndex || old.tabs != tabs;
}
