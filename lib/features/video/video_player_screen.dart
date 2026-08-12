import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/core/services/video_service.dart';
import 'package:visionmusicapp/core/services/app_observability.dart';
import 'package:visionmusicapp/models/video.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/vision_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VideoPlayerScreen
//
// – Chewie for native controls + fullscreen support
// – Pauses AudioManager when video starts
// – Resumes portrait when popped
// – Related videos section
// – YouTube URLs → open in browser
// ─────────────────────────────────────────────────────────────────────────────

class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _vpc;
  ChewieController? _chewie;

  bool _initialising = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _videoCompletionLogged = false;

  List<Video> _related = [];
  bool _loadingRelated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _loadRelated();
  }

  // ── Initialise video ────────────────────────────────────────────────────

  Future<void> _initVideo() async {
    // Unpublished seed entry — never build a controller for a URL that cannot
    // resolve. Without this a placeholder spins, then shows a network error.
    if (!widget.video.isPlayable) {
      if (mounted) setState(() => _initialising = false);
      return;
    }

    // YouTube → cannot play natively; show thumbnail + open-in-browser.
    // Music must still pause here: opening a YouTube video (and then playing
    // it in the browser) should stop the audio track underneath.
    if (widget.video.isYouTube) {
      await _pauseAudioIfPlaying();
      if (mounted) setState(() => _initialising = false);
      return;
    }

    try {
      _vpc = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));
      await _vpc!.initialize();
      _vpc!.addListener(_observeVideoCompletion);

      _chewie = ChewieController(
        videoPlayerController: _vpc!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showOptions: false,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        materialProgressColors: ChewieProgressColors(
          playedColor: kVisionGold,
          handleColor: kVisionGoldLight,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
        placeholder: _thumbnailWidget(),
        errorBuilder: (ctx, msg) => _buildErrorWidget(msg),
      );

      // Pause audio playback when a video starts. Done before autoPlay kicks
      // in so there is no overlap, and failures here must not abort playback.
      await _pauseAudioIfPlaying();
      await AppObservability.instance.videoStarted(widget.video.id);

      if (mounted) setState(() => _initialising = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialising = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // ── Related videos ──────────────────────────────────────────────────────

  void _observeVideoCompletion() {
    final controller = _vpc;
    if (controller == null || _videoCompletionLogged) return;
    final value = controller.value;
    if (!value.isInitialized || value.duration == Duration.zero) return;
    if (value.position >= value.duration - const Duration(milliseconds: 500)) {
      _videoCompletionLogged = true;
      AppObservability.instance.videoCompleted(widget.video.id);
    }
  }

  /// Best-effort pause of the music player when a video or YouTube link is
  /// opened. Own try/catch so a failure here can never abort video init or
  /// playback. Resuming music on exit is intentionally left to the user (they
  /// stopped it to watch a video and may want it to stay quiet).
  Future<void> _pauseAudioIfPlaying() async {
    try {
      final audio = context.read<AudioManager>();
      if (audio.isPlaying) await audio.togglePlayPause();
    } catch (e) {
      debugPrint('Could not pause audio for video: $e');
    }
  }

  Future<void> _loadRelated() async {
    setState(() => _loadingRelated = true);
    try {
      final related = await VideoServiceLocator.instance.fetchRelatedVideos(
        widget.video,
        limit: 6,
      );
      if (mounted) setState(() => _related = related);
    } catch (e) {
      // Related videos are supplementary — a failure here must not interrupt
      // playback, so the section is simply left empty. Logged rather than
      // swallowed, because an empty rail is otherwise indistinguishable from
      // "this video genuinely has no related content".
      debugPrint('Could not load related videos: $e');
    }
    if (mounted) setState(() => _loadingRelated = false);
  }

  // ── Dispose ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    // Restore portrait on exit
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _chewie?.dispose();
    _vpc?.dispose();
    super.dispose();
  }

  // ── YouTube launcher ────────────────────────────────────────────────────

  Future<void> _openYouTube() async {
    final uri = Uri.parse(widget.video.videoUrl);
    if (await canLaunchUrl(uri)) {
      await AppObservability.instance.videoStarted(widget.video.id);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Widgets ─────────────────────────────────────────────────────────────

  Widget _thumbnailWidget() {
    final thumb = widget.video.displayThumbnail;
    return thumb.startsWith('assets/')
        ? Image.asset(
            thumb,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, st) => Container(color: Colors.black),
          )
        : Image.network(
            thumb,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, st) => Container(color: Colors.black),
          );
  }

  Widget _buildErrorWidget(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            msg,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final thumb = video.displayThumbnail;

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
          title: Text(
            _categoryLabel(video.category),
            style: const TextStyle(
              color: kTextMain,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Video area ──────────────────────────────────────────────
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: _buildVideoArea(video, thumb),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(kSpaceM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ─────────────────────────────────────────────
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: kTextMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Artist + duration ─────────────────────────────────
                    Row(
                      children: [
                        Icon(
                          _iconForCategory(video.category),
                          size: 16,
                          color: kVisionGoldLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          video.artistName,
                          style: const TextStyle(
                            color: kVisionGoldLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (video.duration != null) ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: kTextSoft,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _fmtDuration(video.duration),
                            style: const TextStyle(
                              color: kTextSoft,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (video.viewCount > 0) ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.visibility_rounded,
                            size: 13,
                            color: kTextSoft,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _fmtViews(video.viewCount),
                            style: const TextStyle(
                              color: kTextSoft,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: kSpaceM),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: kSpaceM),

                    // ── Description ───────────────────────────────────────
                    if (video.description != null &&
                        video.description!.isNotEmpty) ...[
                      Text(
                        video.description!,
                        style: const TextStyle(
                          color: kTextSoft,
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: kSpaceM),
                    ],

                    // ── Tags ──────────────────────────────────────────────
                    if (video.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: video.tags
                            .map((t) => _TagChip(tag: t))
                            .toList(),
                      ),
                      const SizedBox(height: kSpaceL),
                    ],

                    // ── Related videos ────────────────────────────────────
                    if (_loadingRelated)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(kSpaceM),
                          child: CircularProgressIndicator(
                            color: kVisionGold,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else if (_related.isNotEmpty) ...[
                      const Text(
                        'Up Next',
                        style: TextStyle(
                          color: kTextMain,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: kSpaceS),
                      ..._related.map((v) => _RelatedVideoRow(video: v)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoArea(Video video, String thumb) {
    if (_initialising) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _thumbnailWidget(),
          Container(color: Colors.black54),
          const Center(
            child: CircularProgressIndicator(
              color: kVisionGold,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    }

    // Seed placeholder (videoUrl still contains REPLACE_). Say so plainly
    // rather than opening a player that can never load, or handing the user a
    // dead "Open in YouTube" button that 404s.
    if (!video.isPlayable) {
      return _YouTubeThumbnailArea(
        video: video,
        thumbnailWidget: _thumbnailWidget(),
        onTap: null,
        comingSoon: true,
      );
    }

    // YouTube — cannot play natively
    if (video.isYouTube) {
      return _YouTubeThumbnailArea(
        video: video,
        thumbnailWidget: _thumbnailWidget(),
        onTap: _openYouTube,
      );
    }

    if (_hasError) {
      return _YouTubeThumbnailArea(
        video: video,
        thumbnailWidget: _thumbnailWidget(),
        onTap: null,
        errorMessage: _errorMessage,
      );
    }

    if (_chewie != null) {
      return Chewie(controller: _chewie!);
    }

    return _thumbnailWidget();
  }
}

// ── YouTube thumbnail area ────────────────────────────────────────────────────

class _YouTubeThumbnailArea extends StatelessWidget {
  final Video video;
  final Widget thumbnailWidget;
  final VoidCallback? onTap;
  final String? errorMessage;
  final bool comingSoon;

  const _YouTubeThumbnailArea({
    required this.video,
    required this.thumbnailWidget,
    required this.onTap,
    this.errorMessage,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        thumbnailWidget,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: onTap != null
                        ? kVisionGold.withValues(alpha: 0.92)
                        : Colors.grey.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    comingSoon
                        ? Icons.schedule_rounded
                        : video.isYouTube
                        ? Icons.open_in_new_rounded
                        : Icons.play_arrow_rounded,
                    size: 36,
                    color: Colors.black,
                  ),
                ),
              ),
              if (comingSoon) ...[
                const SizedBox(height: 12),
                const Text(
                  'Coming soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'This video has not been published yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextSoft, fontSize: 13),
                  ),
                ),
              ],
              if (video.isYouTube && onTap != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Open in YouTube',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Error: $errorMessage',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Related video row ─────────────────────────────────────────────────────────

class _RelatedVideoRow extends StatelessWidget {
  final Video video;

  const _RelatedVideoRow({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumb = video.displayThumbnail;

    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: kSpaceS),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kSurfaceDark,
          borderRadius: BorderRadius.circular(kRadiusS),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusXS),
              child: SizedBox(
                width: 100,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumb.startsWith('assets/')
                        ? Image.asset(
                            thumb,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) =>
                                Container(color: kCardBlack),
                          )
                        : Image.network(
                            thumb,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) =>
                                Container(color: kCardBlack),
                          ),
                    Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kVisionGold.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: kSpaceS),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextMain,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    video.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kTextSoft, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(kRadiusL),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(color: kTextSoft, fontSize: 12),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtDuration(Duration? d) {
  if (d == null) return '';
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

String _fmtViews(int views) {
  if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
  if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
  return views.toString();
}

String _categoryLabel(String category) {
  return kDefaultVideoCategories
      .firstWhere(
        (c) => c.id == category,
        orElse: () => const VideoCategory(
          id: '',
          name: 'Video',
          icon: Icons.play_circle_rounded,
        ),
      )
      .name;
}

IconData _iconForCategory(String category) {
  return kDefaultVideoCategories
      .firstWhere(
        (c) => c.id == category,
        orElse: () => const VideoCategory(
          id: '',
          name: 'Video',
          icon: Icons.play_circle_rounded,
        ),
      )
      .icon;
}
