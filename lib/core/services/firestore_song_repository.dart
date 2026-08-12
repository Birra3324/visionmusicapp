import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:visionmusicapp/core/services/song_repository.dart';
import 'package:visionmusicapp/core/services/public_catalog_policy.dart';
import 'package:visionmusicapp/song.dart';

/// Repository backed by a Firestore `songs` collection.
///
/// Expected Firestore document shape (each doc in `songs/`):
/// ```
/// {
///   "id":         "ali_birra_nuho",        // string, required
///   "title":      "Nuho Gobana",            // string, required
///   "artist":     "Ali Birra",              // string, required
///   "albumTitle": "Best of Ali Birra",      // string, optional
///   "genre":      "Oromo Music",            // string, optional
///   "filePath":   "https://...nuho.mp3",    // string, required
///   "imagePath":  "https://...nuho.jpg",    // string, optional
///   "durationMs": 213000,                   // int,    optional
///   "lyrics":     "...",                    // string, optional
///   "youtubeUrl": "https://...",            // string, optional
/// }
/// ```
///
/// Path formats accepted by [MediaSourceResolver], which both the player and
/// the artwork widgets go through:
///
/// * `assets/audio/foo.mp3` — bundled with the app.
/// * `https://...`          — Storage download URL or CDN URL. Preferred.
/// * `gs://bucket/path`     — Storage reference. Works for `filePath` (it is
///   exchanged for a download URL at play time, costing one extra round trip)
///   but NOT for `imagePath`, because Flutter's image pipeline needs a provider
///   synchronously and will fall back to the placeholder logo instead.
///
/// Store https download URLs in `imagePath`. For `filePath`, https is also
/// preferred; use `gs://` only if you need Storage security rules applied
/// per-request.
class FirestoreSongRepository implements SongRepository {
  final FirebaseFirestore _db;

  FirestoreSongRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<Song?> fetchById(String id) async {
    try {
      final snap = await _db.collection('songs').doc(id).get();
      if (!snap.exists) return null;
      final data = snap.data()!;
      if (!PublicCatalogPolicy.isPublishedAndApproved(data)) return null;
      return _songFromMap(snap.id, data);
    } catch (error) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('FirestoreSongRepository.fetchById failed: $error');
      }
      return null;
    }
  }

  @override
  Future<List<Song>> fetchAll() async {
    try {
      final snap = await _db
          .collection('songs')
          .where('status', isEqualTo: 'published')
          .where('approved', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 12));
      return snap.docs
          .map((doc) => _songFromMap(doc.id, doc.data()))
          .whereType<Song>()
          .toList();
    } catch (error, stack) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('FirestoreSongRepository.fetchAll failed: $error\n$stack');
      }
      return const [];
    }
  }

  Song? _songFromMap(String docId, Map<String, dynamic> data) {
    if (!PublicCatalogPolicy.isPublishedAndApproved(data)) return null;
    final title = data['title'] as String?;
    final artist = data['artist'] as String?;
    final filePath = PublicCatalogPolicy.approvedAudioPath(data);
    if (title == null || artist == null || filePath == null) return null;

    return Song(
      id: (data['id'] as String?) ?? docId,
      title: title,
      artist: artist,
      albumTitle: data['albumTitle'] as String?,
      genre: data['genre'] as String?,
      filePath: filePath,
      imagePath: data['imagePath'] as String?,
      duration: Duration(milliseconds: (data['durationMs'] as int?) ?? 0),
      lyrics: data['lyrics'] as String?,
      youtubeUrl: data['youtubeUrl'] as String?,
    );
  }
}
