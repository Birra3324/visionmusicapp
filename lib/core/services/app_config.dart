import 'package:flutter/foundation.dart';

/// App-wide feature flags controlled at compile time.
///
/// Flip [useFirebaseCatalog] to `true` once:
///   1. Firebase is fully configured (`flutterfire configure` ran), and
///   2. You've uploaded songs to the Firestore `songs` collection following
///      the schema documented in `firestore_song_repository.dart`.
///
/// When `false`, the app reads the catalog from the bundled mock list in
/// `lib/mock_songs.dart` — that's the default so the app always has data.
class AppConfig {
  /// Set to `true` to read the catalog from Firestore instead of the bundled
  /// mock list. The Firestore repository falls back to an empty list if it
  /// can't reach Firestore, so combine this with [fallbackToLocalOnEmpty] for
  /// a safe rollout.
  static const bool useFirebaseCatalog = false;

  /// If `true` and the remote catalog is empty (or Firebase isn't ready),
  /// fall back to `mockSongs` so the demo never shows a blank library.
  static const bool fallbackToLocalOnEmpty = true;

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
