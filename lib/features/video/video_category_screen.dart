import 'package:flutter/material.dart';
import 'package:visionmusicapp/features/video/video_player_screen.dart';
import 'package:visionmusicapp/models/video.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VideoCategoryScreen — grid/list of all videos in a category
// ─────────────────────────────────────────────────────────────────────────────

class VideoCategoryScreen extends StatelessWidget {
  final VideoCategory category;
  final List<Video> videos;

  const VideoCategoryScreen({
    super.key,
    required this.category,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final crossAxisCount = screenW > 900
        ? 4
        : screenW > 600
        ? 3
        : 2;

    return VisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: kTextMain),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Icon(category.icon, color: kVisionGoldLight, size: 20),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: const TextStyle(
                  color: kTextMain,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 0.5,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        body: videos.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      color: kTextDim,
                      size: 56,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No videos in this category',
                      style: TextStyle(color: kTextSoft, fontSize: 15),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(kSpaceM),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: kSpaceS,
                  mainAxisSpacing: kSpaceS,
                  childAspectRatio: 16 / 12,
                ),
                itemCount: videos.length,
                itemBuilder: (context, i) => _GridCard(video: videos[i]),
              ),
      ),
    );
  }
}

// ── Grid Card ─────────────────────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  final Video video;

  const _GridCard({required this.video});

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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusM),
          child: Stack(
            fit: StackFit.expand,
            children: [
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

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),

              // Duration badge
              if (video.duration != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _fmtDuration(video.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // Play icon centre
              Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kVisionGold.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),

              // Title + artist
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
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
                        fontSize: 12,
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
                        fontSize: 10,
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
