import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VideoCategory — from Firestore collection `videoCategories`
// ─────────────────────────────────────────────────────────────────────────────

class VideoCategory {
  final String id;
  final String name;
  final IconData icon;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  const VideoCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory VideoCategory.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VideoCategory(
      id: doc.id,
      name: d['name'] as String? ?? doc.id,
      icon: _iconForCategory(d['name'] as String? ?? doc.id),
      imageUrl: d['imageUrl'] as String?,
      sortOrder: (d['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: d['isActive'] as bool? ?? true,
    );
  }

  static IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('music video')) return Icons.music_video_rounded;
    if (lower.contains('live') || lower.contains('performance')) {
      return Icons.stadium_rounded;
    }
    if (lower.contains('studio')) {
      return Icons.mic_external_on_rounded;
    }
    if (lower.contains('interview')) {
      return Icons.mic_rounded;
    }
    if (lower.contains('podcast')) {
      return Icons.podcasts_rounded;
    }
    if (lower.contains('concert')) {
      return Icons.queue_music_rounded;
    }
    if (lower.contains('new') || lower.contains('release')) {
      return Icons.new_releases_rounded;
    }
    if (lower.contains('classic') || lower.contains('oromo')) {
      return Icons.star_rounded;
    }
    return Icons.play_circle_rounded;
  }
}

/// Default categories used when Firestore has none
const List<VideoCategory> kDefaultVideoCategories = [
  VideoCategory(
    id: 'music_videos',
    name: 'Music Videos',
    icon: Icons.music_video_rounded,
    sortOrder: 0,
  ),
  VideoCategory(
    id: 'live_performances',
    name: 'Live Performances',
    icon: Icons.stadium_rounded,
    sortOrder: 1,
  ),
  VideoCategory(
    id: 'studio_sessions',
    name: 'Studio Sessions',
    icon: Icons.mic_external_on_rounded,
    sortOrder: 2,
  ),
  VideoCategory(
    id: 'interviews',
    name: 'Interviews',
    icon: Icons.mic_rounded,
    sortOrder: 3,
  ),
  VideoCategory(
    id: 'podcast_clips',
    name: 'Podcast Clips',
    icon: Icons.podcasts_rounded,
    sortOrder: 4,
  ),
  VideoCategory(
    id: 'concerts',
    name: 'Concerts',
    icon: Icons.queue_music_rounded,
    sortOrder: 5,
  ),
  VideoCategory(
    id: 'new_releases',
    name: 'New Releases',
    icon: Icons.new_releases_rounded,
    sortOrder: 6,
  ),
  VideoCategory(
    id: 'oromo_classics',
    name: 'Oromo Classics',
    icon: Icons.star_rounded,
    sortOrder: 7,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Legacy VideoType enum — kept for backward compat with existing mock data
// ─────────────────────────────────────────────────────────────────────────────

enum VideoType {
  musicVideo,
  podcast,
  interview,
  liveSession,
  documentary,
  userGenerated,
}

extension VideoTypeLabel on VideoType {
  String get label {
    switch (this) {
      case VideoType.musicVideo:
        return 'Music Video';
      case VideoType.podcast:
        return 'Podcast';
      case VideoType.interview:
        return 'Interview';
      case VideoType.liveSession:
        return 'Live Session';
      case VideoType.documentary:
        return 'Documentary';
      case VideoType.userGenerated:
        return 'Community';
    }
  }

  IconData get icon {
    switch (this) {
      case VideoType.musicVideo:
        return Icons.music_video_rounded;
      case VideoType.podcast:
        return Icons.podcasts_rounded;
      case VideoType.interview:
        return Icons.mic_rounded;
      case VideoType.liveSession:
        return Icons.videocam_rounded;
      case VideoType.documentary:
        return Icons.movie_rounded;
      case VideoType.userGenerated:
        return Icons.people_rounded;
    }
  }

  /// Maps VideoType to the string category IDs used in VideoCategory
  String get categoryId {
    switch (this) {
      case VideoType.musicVideo:
        return 'music_videos';
      case VideoType.podcast:
        return 'podcast_clips';
      case VideoType.interview:
        return 'interviews';
      case VideoType.liveSession:
        return 'live_performances';
      case VideoType.documentary:
        return 'oromo_classics';
      case VideoType.userGenerated:
        return 'studio_sessions';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video — main model, Firestore-compatible
// ─────────────────────────────────────────────────────────────────────────────

class Video {
  final String id;
  final String title;

  /// Artist / performer name (Firestore field: `artistName`)
  final String artistName;

  final String? description;

  /// Category string matching VideoCategory.id (Firestore field: `category`)
  final String category;

  /// URL of the thumbnail image (may be a network URL or local asset path)
  final String? thumbnailUrl;

  final String videoUrl;

  final Duration? duration;

  final DateTime? releaseDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool isFeatured;
  final bool isPublished;

  final int viewCount;

  final List<String> tags;

  // ── Legacy field aliases ─────────────────────────────────────────────────
  /// Alias for [artistName] — kept for backward compat with mock_videos.dart
  String get artist => artistName;

  /// Alias for [thumbnailUrl]
  String? get thumbnailPath => thumbnailUrl;

  /// Legacy VideoType derived from category string
  VideoType get type => _typeFromCategory(category);

  // ── Derived helpers ──────────────────────────────────────────────────────
  bool get isYouTube =>
      videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');

  bool get hasThumbnail => thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

  /// Artwork for every video surface in the app.
  ///
  /// Order: explicit thumbnail, then YouTube's own poster frame, then the
  /// brand mark. The middle step matters — it means a video imported from the
  /// channel gets real artwork with no work from us, instead of a wall of
  /// identical logo tiles. All call sites already branch on `assets/` vs
  /// network, so a remote URL here is safe.
  String get displayThumbnail => bestThumbnail;

  /// True while [videoUrl] is still a seed placeholder such as
  /// `https://www.youtube.com/watch?v=REPLACE_ALI_BIRRA_MARKATO`.
  ///
  /// Every entry in `mock_videos.dart` shipped with one of these. They look
  /// like real content in the UI but do nothing when tapped, which reads as a
  /// broken app rather than an empty one. Use [isPlayable] to gate anything
  /// that tries to open a video.
  bool get isPlaceholder =>
      videoUrl.isEmpty ||
      videoUrl.contains('REPLACE_') ||
      videoUrl.contains('EXAMPLE_') ||
      videoUrl.endsWith('watch?v=');

  bool get isPlayable => !isPlaceholder;

  /// True when the video streams directly and can play inside the app via
  /// `video_player`. YouTube links cannot — they open in the browser.
  bool get isInlinePlayable => isPlayable && !isYouTube;

  /// The YouTube video id, parsed from `watch?v=`, `youtu.be/` or `/shorts/`
  /// forms. Returns null for placeholders and non-YouTube URLs.
  String? get youtubeId {
    if (!isYouTube || isPlaceholder) return null;
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return null;

    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    // youtu.be/<id>
    if (uri.host.contains('youtu.be')) return segments.first;

    // youtube.com/shorts/<id>  or  /embed/<id>  or  /v/<id>
    final marker = segments.indexWhere(
      (s) => s == 'shorts' || s == 'embed' || s == 'v',
    );
    if (marker != -1 && marker + 1 < segments.length) {
      return segments[marker + 1];
    }
    return null;
  }

  /// YouTube's auto-generated poster frame, used when no artwork was supplied.
  String? get youtubeThumbnailUrl {
    final vid = youtubeId;
    return vid == null ? null : 'https://img.youtube.com/vi/$vid/hqdefault.jpg';
  }

  /// Best available artwork: explicit thumbnail, then YouTube's poster frame,
  /// then the brand mark.
  String get bestThumbnail {
    if (hasThumbnail) return thumbnailUrl!;
    return youtubeThumbnailUrl ?? 'assets/images/visionlogo.jpg';
  }

  /// `assets/...` paths need Image.asset; everything else needs Image.network.
  bool get thumbnailIsAsset => bestThumbnail.startsWith('assets/');

  // ── Constructor ──────────────────────────────────────────────────────────
  // NOTE: fields with logic in the initializer list must NOT use `this.`
  Video({
    required this.id,
    required this.title,
    required String artistName,
    this.description,
    String? category,
    String? thumbnailUrl, // NOT this.thumbnailUrl — set in initializer
    required this.videoUrl,
    VideoType? type,
    this.duration,
    DateTime? publishedAt,
    this.isFeatured = false,
    this.isPublished = true,
    this.viewCount = 0,
    List<String>? tags,
    this.createdAt,
    this.updatedAt,

    // Legacy compat — if `artist` is passed instead of `artistName`
    String? artist,
    // Legacy compat — if `thumbnailPath` is passed instead of `thumbnailUrl`
    String? thumbnailPath,
    // Legacy compat — release date alias (can't reuse `releaseDate` name)
    DateTime? releaseDateOverride,
  }) : artistName = artistName.isNotEmpty ? artistName : (artist ?? ''),
       category = category ?? _categoryFromType(type),
       thumbnailUrl = thumbnailUrl ?? thumbnailPath,
       tags = tags ?? const [],
       releaseDate = releaseDateOverride ?? publishedAt;

  // ── fromFirestore ────────────────────────────────────────────────────────
  factory Video.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    Duration? dur;
    if (d['duration'] != null) {
      if (d['duration'] is int) {
        dur = Duration(seconds: d['duration'] as int);
      } else if (d['duration'] is String) {
        final parts = (d['duration'] as String).split(':');
        if (parts.length == 2) {
          dur = Duration(
            minutes: int.tryParse(parts[0]) ?? 0,
            seconds: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
    }
    // Legacy field name
    if (dur == null && d['durationSeconds'] != null) {
      dur = Duration(seconds: (d['durationSeconds'] as num).toInt());
    }

    DateTime? releaseDate;
    if (d['releaseDate'] is Timestamp) {
      releaseDate = (d['releaseDate'] as Timestamp).toDate();
    }
    // Legacy field name
    if (releaseDate == null && d['publishedAt'] is Timestamp) {
      releaseDate = (d['publishedAt'] as Timestamp).toDate();
    }

    return Video(
      id: doc.id,
      title: d['title'] as String? ?? '',
      artistName: d['artistName'] as String? ?? d['artist'] as String? ?? '',
      description: d['description'] as String?,
      category:
          d['category'] as String? ??
          _typeFromString(d['type'] as String?).categoryId,
      thumbnailUrl:
          d['thumbnailUrl'] as String? ?? d['thumbnailPath'] as String?,
      videoUrl: d['videoUrl'] as String? ?? '',
      releaseDateOverride: releaseDate,
      isFeatured: d['isFeatured'] as bool? ?? false,
      isPublished: d['isPublished'] as bool? ?? true,
      viewCount: (d['viewCount'] as num?)?.toInt() ?? 0,
      tags: d['tags'] != null ? List<String>.from(d['tags'] as List) : [],
      duration: dur,
      createdAt: d['createdAt'] is Timestamp
          ? (d['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: d['updatedAt'] is Timestamp
          ? (d['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ── toJson / toFirestore ─────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'title': title,
    'artistName': artistName,
    'description': description,
    'category': category,
    'thumbnailUrl': thumbnailUrl,
    'videoUrl': videoUrl,
    'duration': duration?.inSeconds,
    'releaseDate': releaseDate != null
        ? Timestamp.fromDate(releaseDate!)
        : null,
    'isFeatured': isFeatured,
    'isPublished': isPublished,
    'viewCount': viewCount,
    'tags': tags,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };

  Video copyWith({
    String? title,
    String? artistName,
    String? description,
    String? category,
    String? thumbnailUrl,
    String? videoUrl,
    Duration? duration,
    DateTime? releaseDate,
    bool? isFeatured,
    bool? isPublished,
    int? viewCount,
    List<String>? tags,
  }) {
    return Video(
      id: id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      description: description ?? this.description,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      releaseDateOverride: releaseDate ?? this.releaseDate,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublished: isPublished ?? this.isPublished,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// ─── helpers ─────────────────────────────────────────────────────────────────

/// Used in Video() initializer list before instance is available
String _categoryFromType(VideoType? type) {
  if (type == null) return 'music_videos';
  return type.categoryId;
}

VideoType _typeFromCategory(String category) {
  switch (category) {
    case 'music_videos':
      return VideoType.musicVideo;
    case 'podcast_clips':
      return VideoType.podcast;
    case 'interviews':
      return VideoType.interview;
    case 'live_performances':
    case 'concerts':
      return VideoType.liveSession;
    case 'studio_sessions':
      return VideoType.userGenerated;
    case 'oromo_classics':
    case 'new_releases':
      return VideoType.documentary;
    default:
      return VideoType.musicVideo;
  }
}

VideoType _typeFromString(String? type) {
  switch (type) {
    case 'musicVideo':
      return VideoType.musicVideo;
    case 'podcast':
      return VideoType.podcast;
    case 'interview':
      return VideoType.interview;
    case 'liveSession':
      return VideoType.liveSession;
    case 'documentary':
      return VideoType.documentary;
    case 'userGenerated':
      return VideoType.userGenerated;
    default:
      return VideoType.musicVideo;
  }
}
