class LyricsCache {
  static final LyricsCache _instance = LyricsCache._internal();
  final Map<String, String> _cache = {};

  LyricsCache._internal();

  factory LyricsCache() {
    return _instance;
  }

  Future<String?> get(String songId) async {
    return _cache[songId];
  }

  Future<void> set(String songId, String lyrics) async {
    _cache[songId] = lyrics;
  }

  Future<bool> has(String songId) async {
    return _cache.containsKey(songId);
  }

  void clear() {
    _cache.clear();
  }
}
