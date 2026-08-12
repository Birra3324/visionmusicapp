import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Privacy-safe analytics and crash reporting for the listener application.
///
/// Event payloads intentionally use opaque catalog IDs and coarse numeric
/// values only. Names, email addresses, search text, lyrics, and raw URLs must
/// never be passed into this service.
class AppObservability {
  AppObservability._();

  static final AppObservability instance = AppObservability._();

  bool _enabled = false;
  FirebaseAnalytics? _analytics;

  bool get isEnabled => _enabled;

  Future<void> initialize({required bool firebaseReady}) async {
    if (!firebaseReady) return;
    _analytics = FirebaseAnalytics.instance;
    _enabled = true;

    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
  }

  Future<void> event(String name, {Map<String, Object>? parameters}) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[VM-ANALYTICS] $name failed: $error');
      } else {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: false,
          reason: 'Analytics event failed: $name',
        );
      }
    }
  }

  Future<void> recordNonFatal(
    Object error,
    StackTrace stack, {
    required String reason,
  }) async {
    if (!_enabled) return;
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: false,
      reason: reason,
    );
  }

  Future<void> trackImpression(String trackId, String surface) => event(
    'track_impression',
    parameters: {'track_id': trackId, 'surface': surface},
  );

  Future<void> playStarted(String trackId) =>
      event('play_started', parameters: {'track_id': trackId});

  Future<void> playThirtySeconds(String trackId) =>
      event('play_30_seconds', parameters: {'track_id': trackId});

  Future<void> playCompleted(String trackId) =>
      event('play_completed', parameters: {'track_id': trackId});

  Future<void> skip(String trackId, String direction) =>
      event('skip', parameters: {'track_id': trackId, 'direction': direction});

  Future<void> seek(String trackId, int positionSeconds) => event(
    'seek',
    parameters: {'track_id': trackId, 'position_seconds': positionSeconds},
  );

  Future<void> favorite(String trackId, {required bool added}) => event(
    added ? 'favorite' : 'unfavorite',
    parameters: {'track_id': trackId},
  );

  Future<void> search({required bool hasResults}) =>
      event('search', parameters: {'has_results': hasResults ? 1 : 0});

  Future<void> searchResultSelected(String trackId) =>
      event('search_result_selected', parameters: {'track_id': trackId});

  Future<void> artistOpened(String artistId) =>
      event('artist_opened', parameters: {'artist_id': artistId});

  Future<void> albumOpened(String albumId) =>
      event('album_opened', parameters: {'album_id': albumId});

  Future<void> playlistAdd(String trackId) =>
      event('playlist_add', parameters: {'track_id': trackId});

  Future<void> share(String trackId) =>
      event('share', parameters: {'track_id': trackId});

  Future<void> videoStarted(String videoId) =>
      event('video_started', parameters: {'video_id': videoId});

  Future<void> videoCompleted(String videoId) =>
      event('video_completed', parameters: {'video_id': videoId});
}
