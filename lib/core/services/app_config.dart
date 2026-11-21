import 'package:flutter/foundation.dart';

/// Build configuration. Demo data is explicit; a live build never silently
/// substitutes bundled songs when Firebase is unavailable or empty.
class AppConfig {
  static const bool useFirebaseCatalog = bool.fromEnvironment(
    'USE_FIREBASE_CATALOG',
    defaultValue: false,
  );

  /// Read songs from the Vision Music CDN first. On by default; turn off with
  /// `--dart-define=USE_CDN_CATALOG=false`. When the CDN catalog is empty or
  /// unreachable, the app falls through to the Firebase / bundled logic below.
  static const bool useCdnCatalog = bool.fromEnvironment(
    'USE_CDN_CATALOG',
    defaultValue: true,
  );

  /// Base URL of the song CDN (Cloudflare R2 behind a Worker).
  static const String cdnBaseUrl = String.fromEnvironment(
    'CDN_BASE_URL',
    defaultValue: 'https://cdn.visionmusic.et/',
  );

  static const bool fallbackToLocalOnEmpty = bool.fromEnvironment(
    'FALLBACK_TO_LOCAL_CATALOG',
    defaultValue: !useFirebaseCatalog,
  );

  /// Base URL of the music-recognition service, supplied at build time with
  /// `--dart-define=RECOGNITION_BASE_URL=https://...`. Empty by default: the
  /// service is not deployed yet, and a hard-coded localhost URL can never
  /// work on a listener's device.
  static const String recognitionBaseUrl = String.fromEnvironment(
    'RECOGNITION_BASE_URL',
  );

  /// The "identify a song" entry point is shown only when a real recognition
  /// service URL was provided for this build.
  static bool get recognitionEnabled => recognitionBaseUrl.isNotEmpty;

  /// Google Sign-In is hidden on iOS until Sign in with Apple and in-app
  /// account deletion ship (App Store guidelines 4.8 and 5.1.1(v)). iOS
  /// listeners use guest mode, which already covers every listener feature.
  static bool get googleSignInEnabled =>
      kIsWeb || defaultTargetPlatform != TargetPlatform.iOS;
}
