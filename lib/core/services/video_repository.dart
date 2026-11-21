import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:visionmusicapp/core/services/youtube_config.dart';
import 'package:visionmusicapp/core/services/youtube_repository.dart';
import 'package:visionmusicapp/models/video.dart';
import 'package:visionmusicapp/mock_videos.dart';

abstract class VideoRepository {
  Future<List<Video>> getAllVideos();
  Future<List<Video>> getVideosByType(VideoType type);
  Future<Video?> getVideoById(String id);
}

/// Local mock repository for development/offline use
class MockVideoRepository implements VideoRepository {
  @override
  Future<List<Video>> getAllVideos() async => mockVideos;

  @override
  Future<List<Video>> getVideosByType(VideoType type) async {
    return mockVideos.where((v) => v.type == type).toList();
  }

  @override
  Future<Video?> getVideoById(String id) async {
    try {
      return mockVideos.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Firebase Firestore repository for production use
class FirestoreVideoRepository implements VideoRepository {
  final FirebaseFirestore _firestore;

  FirestoreVideoRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _videosCollection => _firestore.collection('videos');

  /// Matches the live Firestore rules (status == 'published' and
  /// approved == true); any other query is refused with PERMISSION_DENIED.
  Query get _publishedVideos => _videosCollection
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

  Video _docToVideo(DocumentSnapshot doc) {
    // Use the canonical Video.fromFirestore() which handles all field aliases
    return Video.fromFirestore(doc);
  }

  @override
  Future<List<Video>> getAllVideos() async {
    try {
      final snapshot = await _publishedVideos.get();
      return _newestFirst(snapshot.docs.map(_docToVideo));
    } catch (e) {
      debugPrint('Error fetching videos from Firestore: $e');
      // Fallback to mock data on error
      return mockVideos;
    }
  }

  @override
  Future<List<Video>> getVideosByType(VideoType type) async {
    try {
      final snapshot = await _publishedVideos
          .where('type', isEqualTo: type.name)
          .get();
      return _newestFirst(snapshot.docs.map(_docToVideo));
    } catch (e) {
      debugPrint('Error fetching videos by type from Firestore: $e');
      // Fallback to mock data
      return mockVideos.where((v) => v.type == type).toList();
    }
  }

  @override
  Future<Video?> getVideoById(String id) async {
    try {
      final doc = await _videosCollection.doc(id).get();
      if (!doc.exists) return null;
      final video = _docToVideo(doc);
      return video.isPublished ? video : null;
    } catch (e) {
      debugPrint('Error fetching video by ID from Firestore: $e');
      // Fallback to mock data
      try {
        return mockVideos.firstWhere((v) => v.id == id);
      } catch (_) {
        return null;
      }
    }
  }
}

/// Factory to create the appropriate repository based on availability
///
/// Priority:
/// 1. YouTube API (if configured with API key)
/// 2. Firebase Firestore (if initialized)
/// 3. Mock data (fallback)
class VideoRepositoryFactory {
  static VideoRepository create({FirebaseFirestore? firestore}) {
    // Check if YouTube API is configured first
    if (YouTubeConfig.isConfigured) {
      debugPrint('YouTube API configured. Using YouTube repository.');
      return YouTubeRepository();
    }

    // Check if Firebase is initialized
    try {
      final fs = firestore ?? FirebaseFirestore.instance;
      // This will throw if Firebase is not initialized
      fs.collection('videos');
      return FirestoreVideoRepository(firestore: fs);
    } catch (e) {
      debugPrint('Firebase not available, using mock video repository');
      return MockVideoRepository();
    }
  }
}
