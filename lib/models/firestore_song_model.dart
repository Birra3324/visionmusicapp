// Firestore Song Model
// Extended Song model with Firestore-specific fields and serialization

import 'package:visionmusicapp/song.dart';

class FirestoreSongModel extends Song {
  // Firestore metadata
  final String? documentId; // Firestore document ID
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? playCount;
  final List<String>? userRatings; // List of user ratings (1-5)
  final List<String>? userComments; // List of comment document IDs

  // AI Metadata
  final String? mood; // 'uplifting', 'melancholic', 'energetic', etc.
  final String? culturalOrigin; // 'oromo', 'ethiopian', etc.
  final List<String>? themes; // ['love', 'freedom', 'tradition', etc.]
  final double? complexityScore; // Lyrical complexity (1-10)
  final String? contentWarning; // Null if safe, otherwise warning text

  // Search/Discovery
  final List<String>? keywords; // Search keywords for discoverability
  final List<String>? relatedSongIds; // IDs of similar songs
  final String? description; // AI-generated description

  FirestoreSongModel({
    required super.id,
    required super.title,
    required super.artist,
    super.albumTitle,
    super.genre,
    required super.filePath,
    super.imagePath,
    super.duration,
    super.theme,
    super.lyrics,
    super.youtubeUrl,
    super.isrc,
    super.upc,
    super.recognitionMetadata,
    super.titleTranslations,
    super.artistTranslations,
    super.lyricsTranslations,
    // Firestore fields
    this.documentId,
    this.createdAt,
    this.updatedAt,
    this.playCount,
    this.userRatings,
    this.userComments,
    // AI fields
    this.mood,
    this.culturalOrigin,
    this.themes,
    this.complexityScore,
    this.contentWarning,
    // Search fields
    this.keywords,
    this.relatedSongIds,
    this.description,
  });

  /// Convert Song to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumTitle': albumTitle,
      'genre': genre,
      'filePath': filePath,
      'imagePath': imagePath,
      'duration': duration.inMilliseconds,
      'lyrics': lyrics,
      'youtubeUrl': youtubeUrl,
      'isrc': isrc,
      'upc': upc,
      'recognitionMetadata': recognitionMetadata,
      'titleTranslations': titleTranslations,
      'artistTranslations': artistTranslations,
      'lyricsTranslations': lyricsTranslations,
      // Firestore metadata
      'documentId': documentId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'playCount': playCount ?? 0,
      'userRatings': userRatings ?? [],
      'userComments': userComments ?? [],
      // AI metadata
      'mood': mood,
      'culturalOrigin': culturalOrigin,
      'themes': themes ?? [],
      'complexityScore': complexityScore,
      'contentWarning': contentWarning,
      // Search fields
      'keywords': keywords ?? [],
      'relatedSongIds': relatedSongIds ?? [],
      'description': description,
    };
  }

  /// Create FirestoreSongModel from Firestore map
  factory FirestoreSongModel.fromFirestore(Map<String, dynamic> data) {
    return FirestoreSongModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      albumTitle: data['albumTitle'],
      genre: data['genre'],
      filePath: data['filePath'] ?? '',
      imagePath: data['imagePath'],
      duration: Duration(milliseconds: data['duration'] ?? 0),
      lyrics: data['lyrics'],
      youtubeUrl: data['youtubeUrl'],
      isrc: data['isrc'],
      upc: data['upc'],
      recognitionMetadata: data['recognitionMetadata'] != null
          ? Map<String, dynamic>.from(data['recognitionMetadata'])
          : null,
      titleTranslations: Map<String, String>.from(
        data['titleTranslations'] ?? {},
      ),
      artistTranslations: Map<String, String>.from(
        data['artistTranslations'] ?? {},
      ),
      lyricsTranslations: Map<String, String>.from(
        data['lyricsTranslations'] ?? {},
      ),
      // Firestore metadata
      documentId: data['documentId'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : null,
      playCount: data['playCount'] ?? 0,
      userRatings: List<String>.from(data['userRatings'] ?? []),
      userComments: List<String>.from(data['userComments'] ?? []),
      // AI metadata
      mood: data['mood'],
      culturalOrigin: data['culturalOrigin'],
      themes: List<String>.from(data['themes'] ?? []),
      complexityScore: (data['complexityScore'] as num?)?.toDouble(),
      contentWarning: data['contentWarning'],
      // Search fields
      keywords: List<String>.from(data['keywords'] ?? []),
      relatedSongIds: List<String>.from(data['relatedSongIds'] ?? []),
      description: data['description'],
    );
  }

  /// Increment play count
  void incrementPlayCount() {
    // TODO: Sync with Firestore
  }

  /// Add user rating
  void addRating(String userId, int rating) {
    // TODO: Sync with Firestore
  }

  /// Add user comment
  void addComment(String commentId) {
    // TODO: Sync with Firestore
  }
}
