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

  /// Marketing-site privacy policy used by Profile and Play Console copy.
  /// The live page / TLS status must be confirmed before a store listing.
  static const String privacyPolicyUrl =
      'https://www.visionmusic.et/privacy.html';

  /// AI Music Assistant has **no production generate backend** in this client
  /// repo. The Profile entry is hidden unless this flag is compiled on.
  ///
  /// Enable only for demos:
  /// `flutter run --dart-define=ENABLE_AI_MUSIC_ASSISTANT=true`
  ///
  /// When enabled, the screen is wired to [UnavailableMusicAiClient] — it
  /// does not call a network URL (none is configured here).
  static bool enableAiMusicAssistant = const bool.fromEnvironment(
    'ENABLE_AI_MUSIC_ASSISTANT',
    defaultValue: false,
  );

  /// Music identification currently posts to a loopback host
  /// (`http://127.0.0.1:8081`). That is not a production endpoint, so the
  /// Search mic entry stays hidden unless this flag is compiled on.
  ///
  /// `flutter run --dart-define=ENABLE_MUSIC_RECOGNITION=true`
  static bool enableMusicRecognition = const bool.fromEnvironment(
    'ENABLE_MUSIC_RECOGNITION',
    defaultValue: false,
  );
}
