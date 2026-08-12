import 'package:visionmusicapp/features/lyrics/lyrics_cache.dart';

/// Lyrics lookup.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// WHY THE PREVIOUS VERSION WAS REMOVED — 11 August 2026
///
/// This file used to ship a `fallbackLyrics` map containing **invented English
/// lyrics** presented as the real lyrics of real Oromo songs by real, living
/// artists. Hirphaa Gaanfuree's track was given words like "Hirphaa, Hirphaa /
/// The voice of our people / Singing freedom's song". Yosan Getahun's was given
/// "the warrior's call / The rhythm of revolution". None of it is real.
///
/// It reached users: `now_playing_screen.dart` renders this on the lyrics
/// sheet, under a spinner reading "Generating lyrics…", which implies a
/// transcription that never happens.
///
/// That is worse than having no lyrics at all:
///
///   * It puts words into named artists' mouths that they never wrote or sang.
///   * It is published by Vision Entertainment, on the artists' own platform,
///     which makes it an attribution problem rather than a harmless stub.
///   * A listener who does not speak Afaan Oromo has no way to tell it is
///     fabricated. It reads as authoritative.
///
/// The fabricated text is preserved at
/// `_recovered-from-apk/superseded-duplicates/lyrics_service.dart.fabricated-backup`
/// so nothing is destroyed — but it must not be displayed again.
///
/// The architecture stays intact so licensed lyrics can drop in: the cache,
/// the per-language lookup and the call site are unchanged. Only the invented
/// content is gone, replaced by an honest empty result.
///
/// TO IMPLEMENT PROPERLY: use a licensed provider (Musixmatch, LyricFind) or
/// lyrics supplied by the artists themselves through Vision Entertainment.
/// Do not scrape, and do not generate.
/// ─────────────────────────────────────────────────────────────────────────────
class LyricsService {
  static final LyricsService _instance = LyricsService._internal();
  final LyricsCache _cache = LyricsCache();

  LyricsService._internal();

  factory LyricsService() => _instance;

  /// Real lyrics, keyed by song title, then language code.
  ///
  /// Deliberately empty. Populate only with words the artist actually wrote,
  /// from a licensed source or supplied directly. An entry here is a claim
  /// about what someone sang, so it must be true.
  static final Map<String, Map<String, String>> licensedLyrics = {};

  /// Returns lyrics for a track, or null when none are available.
  ///
  /// Null is meaningful: the UI must show "no lyrics yet" rather than filler.
  /// Callers should not substitute placeholder text of their own.
  Future<String?> getLyrics(
    String songId,
    String songTitle, {
    String languageCode = 'en',
  }) async {
    final cacheKey = '$songId-$languageCode';

    final cached = await _cache.get(cacheKey);
    if (cached != null && cached.isNotEmpty) return cached;

    final forTitle = licensedLyrics[songTitle];
    if (forTitle == null) return null;

    // Requested language, then English, then whatever exists — but never
    // anything invented.
    final lyrics = forTitle[languageCode] ?? forTitle['en'];
    if (lyrics == null || lyrics.isEmpty) return null;

    await _cache.set(cacheKey, lyrics);
    return lyrics;
  }

  /// Whether lyrics exist for a track, without fetching them. Lets the UI hide
  /// a lyrics affordance entirely rather than offering one that leads nowhere.
  bool hasLyrics(String songTitle) {
    final forTitle = licensedLyrics[songTitle];
    return forTitle != null && forTitle.isNotEmpty;
  }
}
