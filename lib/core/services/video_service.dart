import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:visionmusicapp/core/services/app_config.dart';
import 'package:visionmusicapp/mock_videos.dart';
import 'package:visionmusicapp/models/video.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VideoService
//
// Single source of truth for all video data.
// Catalog mode matches music; demo fallback must be explicitly enabled.
//
// Firestore collections:
//   videos/{videoId}
//   videoCategories/{categoryId}
// ─────────────────────────────────────────────────────────────────────────────

class VideoService {
  final FirebaseFirestore? _firestore;

  final Duration _requestTimeout;
  final bool _useFirebase;
  final bool _allowLocalFallback;

  VideoService({
    this._firestore,
    this._requestTimeout = const Duration(seconds: 12),
    this._useFirebase = AppConfig.useFirebaseCatalog,
    this._allowLocalFallback = AppConfig.fallbackToLocalOnEmpty,
  });

  List<Video> get _fallbackVideos =>
      !_useFirebase || _allowLocalFallback ? mockVideos : const [];

  List<Video> get _fallbackFeatured =>
      _fallbackVideos.where((video) => video.isFeatured).toList();

  // ── Firestore helpers ────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>>? get _videosRef {
    try {
      return (_firestore ?? FirebaseFirestore.instance).collection('videos');
    } catch (_) {
      return null;
    }
  }

  Query<Map<String, dynamic>> get _publishedVideos => _videosRef!
      .where('status', isEqualTo: 'published')
      .where('approved', isEqualTo: true);

  CollectionReference? get _categoriesRef {
    try {
      return (_firestore ?? FirebaseFirestore.instance).collection(
        'videoCategories',
      );
    } catch (_) {
      return null;
    }
  }

  bool get _firestoreAvailable => _useFirebase && _videosRef != null;

  // ── Public API ───────────────────────────────────────────────────────────

  /// All published videos, newest first.
  Future<List<Video>> fetchAllVideos() async {
    if (!_firestoreAvailable) return _fallbackVideos;
    try {
      final snap = await _publishedVideos
          .orderBy('releaseDate', descending: true)
          .get()
          .timeout(_requestTimeout);
      final results = snap.docs.map(Video.fromFirestore).toList();
      return results.isEmpty ? _fallbackVideos : results;
    } catch (e) {
      debugPrint('[VideoService] fetchAllVideos error: $e');
      if (_useFirebase && !_allowLocalFallback) rethrow;
      return _fallbackVideos;
    }
  }

  /// Featured videos for the hero banner.
  Future<List<Video>> fetchFeaturedVideos() async {
    if (!_firestoreAvailable) return _fallbackFeatured;
    try {
      final snap = await _publishedVideos
          .where('isFeatured', isEqualTo: true)
          .orderBy('releaseDate', descending: true)
          .get()
          .timeout(_requestTimeout);
      final results = snap.docs.map(Video.fromFirestore).toList();
      return results.isEmpty ? _fallbackFeatured : results;
    } catch (e) {
      debugPrint('[VideoService] fetchFeaturedVideos error: $e');
      if (_useFirebase && !_allowLocalFallback) rethrow;
      return _fallbackFeatured;
    }
  }

  /// Video categories, sorted by sortOrder.
  Future<List<VideoCategory>> fetchVideoCategories() async {
    if (!_firestoreAvailable) return kDefaultVideoCategories;
    try {
      final snap = await _categoriesRef!
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get()
          .timeout(_requestTimeout);
      if (snap.docs.isEmpty) return kDefaultVideoCategories;
      return snap.docs.map(VideoCategory.fromFirestore).toList();
    } catch (e) {
      debugPrint('[VideoService] fetchVideoCategories error: $e');
      if (_useFirebase && !_allowLocalFallback) rethrow;
      return kDefaultVideoCategories;
    }
  }

  /// Videos in a given category, newest first.
  Future<List<Video>> fetchVideosByCategory(String categoryId) async {
    if (!_firestoreAvailable) {
      return _fallbackVideos.where((v) => v.category == categoryId).toList();
    }
    try {
      final snap = await _publishedVideos
          .where('category', isEqualTo: categoryId)
          .orderBy('releaseDate', descending: true)
          .get()
          .timeout(_requestTimeout);
      final results = snap.docs.map(Video.fromFirestore).toList();
      if (results.isEmpty) {
        return _fallbackVideos.where((v) => v.category == categoryId).toList();
      }
      return results;
    } catch (e) {
      debugPrint('[VideoService] fetchVideosByCategory($categoryId) error: $e');
      if (_useFirebase && !_allowLocalFallback) rethrow;
      return _fallbackVideos.where((v) => v.category == categoryId).toList();
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
    // One catalog read avoids a sequential network request for every category.
    final all = await fetchAllVideos();
    final map = <String, List<Video>>{};
    for (final cat in categories) {
      final videos = all.where((video) => video.category == cat.id).toList();
      if (videos.isNotEmpty) map[cat.id] = videos;
    }
    return map;
  }

  /// Single video by ID.
  Future<Video?> fetchVideoById(String id) async {
    if (!_firestoreAvailable) {
      try {
        return _fallbackVideos.firstWhere((v) => v.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final doc = await _videosRef!.doc(id).get().timeout(_requestTimeout);
      final data = doc.data();
      if (data?['status'] != 'published' || data?['approved'] != true) {
        return null;
      }
      return Video.fromFirestore(doc);
    } catch (e) {
      debugPrint('[VideoService] fetchVideoById($id) error: $e');
      if (_useFirebase && !_allowLocalFallback) rethrow;
      try {
        return _fallbackVideos.firstWhere((v) => v.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// Increment view count (fire-and-forget — not critical).
  Future<void> incrementViewCount(String videoId) async {
    if (!_firestoreAvailable) return;
    try {
      await _videosRef!
          .doc(videoId)
          .update({'viewCount': FieldValue.increment(1)})
          .timeout(_requestTimeout);
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
