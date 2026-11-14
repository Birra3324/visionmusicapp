import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/core/services/app_config.dart';
import 'package:visionmusicapp/core/services/catalog_loader.dart';

void main() {
  test('live builds do not silently enable demo fallback', () {
    if (AppConfig.useFirebaseCatalog) {
      expect(AppConfig.fallbackToLocalOnEmpty, isFalse);
    }
  });
  test('live mode uses remote songs and never mixes in demo songs', () async {
    final songs = await loadCatalog<String>(
      useFirebase: true,
      firebaseReady: true,
      allowLocalFallback: false,
      loadRemote: () async => ['approved remote'],
      loadLocal: () async => throw StateError('demo must not be loaded'),
    );
    expect(songs, ['approved remote']);
  });
  test('empty or unavailable Firebase never falls back in live mode', () async {
    for (final ready in [true, false]) {
      final songs = await loadCatalog<String>(
        useFirebase: true,
        firebaseReady: ready,
        allowLocalFallback: false,
        loadRemote: () async => [],
        loadLocal: () async => throw StateError('demo must not be loaded'),
      );
      expect(songs, isEmpty);
    }
  });
  test('demo mode and explicit demo fallback remain available', () async {
    for (final useFirebase in [true, false]) {
      final songs = await loadCatalog<String>(
        useFirebase: useFirebase,
        firebaseReady: false,
        allowLocalFallback: true,
        loadRemote: () async => throw StateError('Firebase is unavailable'),
        loadLocal: () async => ['demo'],
      );
      expect(songs, ['demo']);
    }
  });
}
