// Search Enhancement Service
// Adds multilingual search support with automatic language detection
// Enables searching for songs in any supported language

import 'package:visionmusicapp/song.dart';

class SearchEnhancementService {
  static final SearchEnhancementService _instance =
      SearchEnhancementService._internal();

  factory SearchEnhancementService() => _instance;
  SearchEnhancementService._internal();

  // A translator instance used to live here, but AITranslationService is still
  // a stub and nothing in this class ever called it. Reinstate it when real
  // translation exists — a dead dependency implies a feature that is not there.

  /// Search songs with multilingual support
  /// Searches across: title, artist, genre in all available languages
  Future<List<Song>> searchSongs(
    String query,
    List<Song> allSongs, {
    required String currentLanguage,
  }) async {
    if (query.isEmpty) return [];

    final results = <Song>[];

    // First: Direct match in current language
    for (final song in allSongs) {
      if (_matchesSong(song, query, currentLanguage)) {
        results.add(song);
      }
    }

    // TODO: Second pass - translate query to other languages and search
    // This would require API connectivity for real translation

    return results;
  }

  /// Check if song matches query in given language
  bool _matchesSong(Song song, String query, String language) {
    final queryLower = query.toLowerCase();

    // Check original fields
    if (song.title.toLowerCase().contains(queryLower)) return true;
    if (song.artist.toLowerCase().contains(queryLower)) return true;
    if (song.genre?.toLowerCase().contains(queryLower) ?? false) return true;

    // Check localized fields if available
    if (language != 'en') {
      final localizedTitle = song.getLocalizedTitle(language);
      final localizedArtist = song.getLocalizedArtist(language);

      if (localizedTitle.toLowerCase().contains(queryLower)) return true;
      if (localizedArtist.toLowerCase().contains(queryLower)) return true;
    }

    return false;
  }

  /// Get search suggestions based on user input
  /// Returns list of song titles and artists that match
  Future<List<String>> getSearchSuggestions(
    String query,
    List<Song> allSongs,
  ) async {
    if (query.isEmpty) return [];

    final suggestions = <String>{};
    final queryLower = query.toLowerCase();

    for (final song in allSongs) {
      if (song.title.toLowerCase().contains(queryLower)) {
        suggestions.add(song.title);
      }
      if (song.artist.toLowerCase().contains(queryLower)) {
        suggestions.add(song.artist);
      }
    }

    return suggestions.toList();
  }

  /// Detect language of search query
  /// Helps narrow down which language version to prioritize
  Future<String> detectSearchLanguage(String query) async {
    // TODO: Implement language detection for search query
    // Use AITranslationService.detectLanguage()
    return 'en'; // Placeholder
  }
}
