import 'package:flutter/material.dart';
import 'package:visionmusicapp/core/services/video_service.dart';
import 'package:visionmusicapp/features/video/video_category_screen.dart';
import 'package:visionmusicapp/features/video/video_player_screen.dart';
import 'package:visionmusicapp/models/video.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VideoHubScreen — Premium Netflix-style video home
// ─────────────────────────────────────────────────────────────────────────────

class VideoHubScreen extends StatefulWidget {
  const VideoHubScreen({super.key});

  @override
  State<VideoHubScreen> createState() => _VideoHubScreenState();
}

class _VideoHubScreenState extends State<VideoHubScreen> {
  final VideoService _service = VideoServiceLocator.instance;

  List<Video> _featured = [];
  List<VideoCategory> _categories = [];
  Map<String, List<Video>> _byCategory = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final cats = await _service.fetchVideoCategories();
      final featured = await _service.fetchFeaturedVideos();
      final byCategory = await _service.fetchVideosByAllCategories(cats);

      if (mounted) {
        setState(() {
          _categories = cats;
          _featured = featured;
          _byCategory = byCategory;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _loading
            ? const _LoadingView()
            : _error != null
            ? _ErrorView(error: _error!, onRetry: _load)
            : _ContentView(
                featured: _featured,
                categories: _categories,
                byCategory: _byCategory,
                onRefresh: _load,
              ),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: kVisionGold, strokeWidth: 2),
          SizedBox(height: 20),
          Text(
            'Loading videos…',
            style: TextStyle(color: kTextSoft, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: kTextDim, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Could not load videos',
              style: TextStyle(
                color: kTextMain,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: kTextSoft, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: kVisionGold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main content ──────────────────────────────────────────────────────────────

class _ContentView extends StatelessWidget {
  final List<Video> featured;
  final List<VideoCategory> categories;
  final Map<String, List<Video>> byCategory;
  final Future<void> Function() onRefresh;

  const _ContentView({
    required this.featured,
    required this.categories,
    required this.byCategory,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: kVisionGold,
      backgroundColor: kDarkCard,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: kAppBackground.withValues(alpha: 0.92),
            title: const Row(
              children: [
                Icon(Icons.play_circle_rounded, color: kVisionGold, size: 22),
                SizedBox(width: 8),
                Text(
                  'Watch',
                  style: TextStyle(
                    color: kTextMain,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search_rounded,
                  color: kTextMain,
                  size: 22,
                ),
                tooltip: 'Search videos',
                onPressed: () {
                  final videos = <String, Video>{};
                  for (final video in featured) {
                    videos[video.id] = video;
                  }
                  for (final list in byCategory.values) {
                    for (final video in list) {
                      videos[video.id] = video;
                    }
                  }
                  showSearch<void>(
                    context: context,
                    delegate: _VideoSearchDelegate(videos.values.toList()),
                  );
                },
              ),
            ],
          ),

          // ── Featured Hero ────────────────────────────────────────────────
          if (featured.isNotEmpty)
            SliverToBoxAdapter(child: _FeaturedHero(videos: featured)),

          // ── Category rows ────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final cat = categories[i];
              final videos = byCategory[cat.id];
              if (videos == null || videos.isEmpty) {
                return const SizedBox.shrink();
              }
              return _CategoryRow(category: cat, videos: videos);
            }, childCount: categories.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _VideoSearchDelegate extends SearchDelegate<void> {
  final List<Video> videos;

  _VideoSearchDelegate(this.videos)
    : super(
        searchFieldLabel: 'Videos and artists',
        searchFieldStyle: const TextStyle(color: kTextMain),
      );

  @override
  ThemeData appBarTheme(BuildContext context) =>
      buildVisionGoldTheme().copyWith(scaffoldBackgroundColor: kAppBackground);

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Clear',
        onPressed: () => query = '',
        icon: const Icon(Icons.close_rounded),
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    tooltip: 'Back',
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back_rounded),
  );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final normalized = query.trim().toLowerCase();
    final matches = normalized.isEmpty
        ? videos
        : videos
              .where(
                (video) =>
                    video.title.toLowerCase().contains(normalized) ||
                    video.artistName.toLowerCase().contains(normalized),
              )
              .toList();

    if (matches.isEmpty) {
      return const Center(
        child: Text('No matching videos.', style: TextStyle(color: kTextSoft)),
      );
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final video = matches[index];
        return ListTile(
          leading: const Icon(
            Icons.play_circle_outline_rounded,
            color: kVisionGold,
          ),
          title: Text(video.title, style: const TextStyle(color: kTextMain)),
          subtitle: Text(
            video.artistName,
            style: const TextStyle(color: kTextSoft),
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(video: video),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Featured Hero Banner ──────────────────────────────────────────────────────

class _FeaturedHero extends StatefulWidget {
  final List<Video> videos;

  const _FeaturedHero({required this.videos});

  @override
  State<_FeaturedHero> createState() => _FeaturedHeroState();
}

class _FeaturedHeroState extends State<_FeaturedHero> {
  int _current = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.videos.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final next = (_current + 1) % widget.videos.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final heroHeight = screenW > 600 ? 380.0 : 280.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.videos.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => _FeaturedCard(video: widget.videos[i]),
          ),
          // Page dots
          if (widget.videos.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.videos.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _current ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _current ? kVisionGold : Colors.white60,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Video video;

  const _FeaturedCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumb = video.displayThumbnail;

    return GestureDetector(
      onTap: () => _openPlayer(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          thumb.startsWith('assets/')
              ? Image.asset(
                  thumb,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) =>
                      Container(color: kSurfaceDark),
                )
              : Image.network(
                  thumb,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) =>
                      Container(color: kSurfaceDark),
                ),

          // Gradient overlay — bottom heavy
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),

          // Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Featured badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kVisionGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  video.artistName,
                  style: const TextStyle(color: kVisionGoldLight, fontSize: 14),
                ),
                const SizedBox(height: 14),
                // Play button
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => _openPlayer(context),
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Play',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: kVisionGold,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kRadiusS),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
    );
  }
}

// ── Category Row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final VideoCategory category;
  final List<Video> videos;

  const _CategoryRow({required this.category, required this.videos});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardWidth = screenW > 600 ? 300.0 : 220.0;
    final cardHeight = screenW > 600 ? 190.0 : 148.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            kSpaceM,
            kSpaceL,
            kSpaceM,
            kSpaceS,
          ),
          child: Row(
            children: [
              Icon(category.icon, color: kVisionGoldLight, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: kTextMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VideoCategoryScreen(category: category, videos: videos),
                  ),
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: kVisionGold.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Horizontal scroll
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kSpaceM),
            itemCount: videos.length,
            itemBuilder: (context, i) => _VideoThumbCard(
              video: videos[i],
              width: cardWidth,
              height: cardHeight,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Video Thumbnail Card ──────────────────────────────────────────────────────

class _VideoThumbCard extends StatelessWidget {
  final Video video;
  final double width;
  final double height;

  const _VideoThumbCard({
    required this.video,
    required this.width,
    required this.height,
  });

  String _fmtDuration(Duration? d) {
    if (d == null) return '';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final thumb = video.displayThumbnail;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
      ),
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: kSpaceS),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusM),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              thumb.startsWith('assets/')
                  ? Image.asset(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) =>
                          Container(color: kSurfaceDark),
                    )
                  : Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) =>
                          Container(color: kSurfaceDark),
                    ),

              // Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),

              // Duration badge
              if (video.duration != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      _fmtDuration(video.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // Play button (centre)
              Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kVisionGold.withValues(alpha: 0.88),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),

              // Title + artist (bottom)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
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
                      video.artistName,
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
            ],
          ),
        ),
      ),
    );
  }
}
