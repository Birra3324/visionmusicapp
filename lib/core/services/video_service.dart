import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:visionmusicapp/mock_videos.dart';
import 'package:visionmusicapp/models/video.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VideoService
//
// Single source of truth for all video data.
// Priority:  Firestore → mock fallback
//
// Firestore collections:
//   videos/{videoId}
//   videoCategories/{categoryId}
// ─────────────────────────────────────────────────────────────────────────────

class VideoService {
  final FirebaseFirestore? _firestore;

  VideoService({FirebaseFirestore? firestore}) : _firestore = firestore;

  // ── Firestore helpers ────────────────────────────────────────────────────

  CollectionReference? get _videosRef {
    try {
      return (_firestore ?? FirebaseFirestore.instance).collection('videos');
    } catch (_) {
      return null;
    }
  }

  CollectionReference? get _categoriesRef {
    try {
      return (_firestore ?? FirebaseFirestore.instance).collection(
        'videoCategories',
      );
    } catch (_) {
      return null;
    }
  }

  bool get _firestoreAvailable => _videosRef != null;

  /// Published videos only. The live Firestore rules allow reading a video
  /// only when `status == 'published'` and `approved == true`, and Firestore
  /// refuses any query that could return a document the rules deny. Every
  /// video query must start here or it fails with PERMISSION_DENIED.
  Query get _publishedVideos => _videosRef!
      .where('status', isEqualTo: 'published')
      .where('approved', isEqualTo: true);

  /// Newest first, sorted on the device so no composite index is needed.
  static List<Video> _newestFirst(Iterable<Video> videos) {
    final list = videos.toList();
    list.sort((a, b) {
      final ad = a.releaseDate, bd = b.releaseDate;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return list;
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// All published videos, newest first.
  Future<List<Video>> fetchAllVideos() async {
    if (!_firestoreAvailable) return mockVideos;
    try {
      final snap = await _publishedVideos.get();
      final results = _newestFirst(snap.docs.map(Video.fromFirestore));
      return results.isEmpty ? mockVideos : results;
    } catch (e) {
      debugPrint('[VideoService] fetchAllVideos error: $e');
      return mockVideos;
    }
  }

  /// Featured videos for the hero banner.
  Future<List<Video>> fetchFeaturedVideos() async {
    if (!_firestoreAvailable) return featuredMockVideos;
    try {
      final snap = await _publishedVideos
          .where('isFeatured', isEqualTo: true)
          .get();
      final results = _newestFirst(snap.docs.map(Video.fromFirestore));
      return results.isEmpty ? featuredMockVideos : results;
    } catch (e) {
      debugPrint('[VideoService] fetchFeaturedVideos error: $e');
      return featuredMockVideos;
    }
  }

  /// Video categories, sorted by sortOrder.
  Future<List<VideoCategory>> fetchVideoCategories() async {
    if (!_firestoreAvailable) return kDefaultVideoCategories;
    try {
      final snap = await _categoriesRef!
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();
      if (snap.docs.isEmpty) return kDefaultVideoCategories;
      return snap.docs.map(VideoCategory.fromFirestore).toList();
    } catch (e) {
      debugPrint('[VideoService] fetchVideoCategories error: $e');
      return kDefaultVideoCategories;
    }
  }

  /// Videos in a given category, newest first.
  Future<List<Video>> fetchVideosByCategory(String categoryId) async {
    if (!_firestoreAvailable) {
      return mockVideos.where((v) => v.category == categoryId).toList();
    }
    try {
      final snap = await _publishedVideos
          .where('category', isEqualTo: categoryId)
          .get();
      final results = _newestFirst(snap.docs.map(Video.fromFirestore));
      if (results.isEmpty) {
        return mockVideos.where((v) => v.category == categoryId).toList();
      }
      return results;
    } catch (e) {
      debugPrint('[VideoService] fetchVideosByCategory($categoryId) error: $e');
      return mockVideos.where((v) => v.category == categoryId).toList();
    }
  }

  /// Related videos — same category, excluding the given video.
  Future<List<Video>> fetchRelatedVideos(Video video, {int limit = 8}) async {
    final all = await fetchVideosByCategory(video.category);
    final related = all.where((v) => v.id != video.id).take(limit).toList();
    // If the category had fewer than 2 videos, fall back to other categories
    if (related.isEmpty) {
      final allVideos = await fetchAllVideos();
      return allVideos.where((v) => v.id != video.id).take(limit).toList();
    }
    return related;
  }

  /// Videos grouped by category — used by VideoHomeScreen.
  Future<Map<String, List<Video>>> fetchVideosByAllCategories(
    List<VideoCategory> categories,
  ) async {
    final map = <String, List<Video>>{};
    for (final cat in categories) {
      final videos = await fetchVideosByCategory(cat.id);
      if (videos.isNotEmpty) {
        map[cat.id] = videos;
      }
    }
    return map;
  }

  /// Single video by ID.
  Future<Video?> fetchVideoById(String id) async {
    if (!_firestoreAvailable) {
      try {
        return mockVideos.firstWhere((v) => v.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final doc = await _videosRef!.doc(id).get();
      if (!doc.exists) return null;
      return Video.fromFirestore(doc);
    } catch (e) {
      debugPrint('[VideoService] fetchVideoById($id) error: $e');
      try {
        return mockVideos.firstWhere((v) => v.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// View counts are not written from the app: the Firestore rules deny every
  /// client write to `videos/`, so the old `update()` failed on every play.
  /// Count views on the server side instead (e.g. a Worker or Cloud Function).
  Future<void> incrementViewCount(String videoId) async {}
}

/// Singleton instance — initialised once in main.dart
class VideoServiceLocator {
  static VideoService? _instance;

  static VideoService get instance {
    _instance ??= VideoService();
    return _instance!;
  }

  static void init({FirebaseFirestore? firestore}) {
    _instance = VideoService(firestore: firestore);
  }
}
