import 'package:flutter/material.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String? albumTitle;
  final String? genre;
  final String filePath;
  final String? imagePath;
  final Duration duration;
  final List<Color>? theme;
  final String? lyrics;
  final String? youtubeUrl;

  // Recognition Metadata
  final String? isrc;
  final String? upc;
  final Map<String, dynamic>? recognitionMetadata;

  // Localized content maps (language code -> content)
  final Map<String, String>?
  titleTranslations; // 'om' -> Oromo title, 'ar' -> Arabic title, etc.
  final Map<String, String>? artistTranslations;
  final Map<String, String>?
  lyricsTranslations; // 'om' -> Oromo lyrics, 'fr' -> French lyrics, etc.

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.albumTitle,
    this.genre,
    required this.filePath,
    this.imagePath,
    this.duration = Duration.zero,
    this.theme,
    this.lyrics,
    this.youtubeUrl,
    this.isrc,
    this.upc,
    this.recognitionMetadata,
    this.titleTranslations,
    this.artistTranslations,
    this.lyricsTranslations,
  });

  /// Get localized title for a given language code
  /// Falls back to original title if translation not available
  String getLocalizedTitle(String languageCode) {
    if (languageCode == 'en') return title;
    return titleTranslations?[languageCode] ?? title;
  }

  /// Get localized artist for a given language code
  /// Falls back to original artist if translation not available
  String getLocalizedArtist(String languageCode) {
    if (languageCode == 'en') return artist;
    return artistTranslations?[languageCode] ?? artist;
  }

  /// Get localized lyrics for a given language code
  /// Falls back to original lyrics if translation not available
  String? getLocalizedLyrics(String languageCode) {
    if (languageCode == 'en') return lyrics;
    return lyricsTranslations?[languageCode] ?? lyrics;
  }

  /// Identity is [id] alone.
  ///
  /// This matters more than it looks. `AudioManager` relies on
  /// `_queue.indexOf(song)` and `_queue.contains(song)`. While the catalog
  /// comes from the compile-time `const mockSongs` list, Dart canonicalises
  /// identical const instances and reference equality happens to work. The
  /// moment the catalog is served from Firestore, every `Song` becomes a
  /// fresh non-const object, `indexOf` returns -1, and `playSong` silently
  /// falls through to `setQueue([song])` — wiping the user's queue on every
  /// tap. Keying equality on `id` prevents that.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Song && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song($id: $title — $artist)';
}
