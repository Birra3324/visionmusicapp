/// Saves songs on the phone as they stream, so a song played once plays again
/// without using mobile data and keeps playing when the connection drops.
///
/// On Android the player streams through just_audio's
/// [LockCachingAudioSource], which writes the file to the app's cache folder
/// while it plays. Android may clear that folder when the phone runs low on
/// space, and [pruneAudioCache] keeps it under [audioCacheMaxBytes].
///
/// iOS and the web stream as before: on iOS the caching proxy needs an App
/// Transport Security exception for local networking, which is left for a
/// separate, App Review-checked change.
library;

export 'audio_cache_stub.dart' if (dart.library.io) 'audio_cache_io.dart';

/// Upper bound for saved songs. 300 MB holds about 150 songs at 128 kbps.
const int audioCacheMaxBytes = 300 * 1024 * 1024;

/// Stable short file name for a URL (two 32-bit FNV-1a hashes), so the same
/// song version always maps to the same cached file. A new version on the CDN
/// has a new URL, so it is downloaded fresh. 32-bit arithmetic keeps this
/// identical on the web, where Dart integers are JavaScript numbers.
String audioCacheKey(String url) {
  String fnv32(int seed) {
    var hash = seed;
    for (final unit in url.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  return fnv32(0x811c9dc5) + fnv32(0x050c5d1f);
}
