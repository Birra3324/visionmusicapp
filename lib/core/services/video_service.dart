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

  // ── Public API ───────────────────────────────────────────────────────────

  /// All published videos, newest first.
  Future<List<Video>> fetchAllVideos() async {
    if (!_firestoreAvailable) return mockVideos;
    try {
      final snap = await _videosRef!
          .where('isPublished', isEqualTo: true)
          .orderBy('releaseDate', descending: true)
          .get();
      final results = snap.docs.map(Video.fromFirestore).toList();
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
      final snap = await _videosRef!
          .where('isPublished', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('releaseDate', descending: true)
          .get();
      final results = snap.docs.map(Video.fromFirestore).toList();
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
      final snap = await _videosRef!
          .where('isPublished', isEqualTo: true)
          .where('category', isEqualTo: categoryId)
          .orderBy('releaseDate', descending: true)
          .get();
      final results = snap.docs.map(Video.fromFirestore).toList();
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

  /// Increment view count (fire-and-forget — not critical).
  Future<void> incrementViewCount(String videoId) async {
    if (!_firestoreAvailable) return;
    try {
      await _videosRef!.doc(videoId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('[VideoService] incrementViewCount error: $e');
    }
  }
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
