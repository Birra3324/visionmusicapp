import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:visionmusicapp/core/services/catalog_cache.dart';
import 'package:visionmusicapp/core/services/cdn_song_repository.dart';

const _base = 'https://cdn.visionmusic.et/';

String _catalog(String id) => jsonEncode({
      'schemaVersion': 1,
      'songs': [
        {
          'id': id,
          'title': 'T $id',
          'artist': 'A',
          'durationMs': 1000,
          'renditions': {
            'aac128': {'path': 'songs/$id/1/aac128.m4a'},
          },
        },
      ],
    });

CdnSongRepository _repo(MockClient client, CatalogCache cache) =>
    CdnSongRepository(
      baseUrl: _base,
      client: client,
      cache: cache,
      timeout: const Duration(milliseconds: 400),
      cachedTimeout: const Duration(milliseconds: 100),
    );

void main() {
  test('a good catalog is shown and saved for next time', () async {
    final cache = MemoryCatalogCache();
    final songs = await _repo(
      MockClient((_) async => http.Response(_catalog('new'), 200)),
      cache,
    ).fetchAll();
    expect(songs.single.id, 'new');
    expect(cache.writes, 1);
    expect(cache.body, contains('"new"'));
  });

  test('CDN down: the saved catalog keeps the app working', () async {
    final cache = MemoryCatalogCache(_catalog('saved'));
    final songs = await _repo(
      MockClient((_) async => throw const SocketLikeException()),
      cache,
    ).fetchAll();
    expect(songs.single.id, 'saved');
  });

  test('server error does not replace the saved catalog', () async {
    final cache = MemoryCatalogCache(_catalog('saved'));
    final songs = await _repo(
      MockClient((_) async => http.Response('oops', 503)),
      cache,
    ).fetchAll();
    expect(songs.single.id, 'saved');
    expect(cache.writes, 0);
  });

  test('an empty or broken catalog does not overwrite a good one', () async {
    final cache = MemoryCatalogCache(_catalog('saved'));
    final songs = await _repo(
      MockClient((_) async => http.Response('{"songs": []}', 200)),
      cache,
    ).fetchAll();
    expect(songs.single.id, 'saved');
    expect(cache.writes, 0);
  });

  test('slow CDN with a saved catalog: waits only the short timeout',
      () async {
    final cache = MemoryCatalogCache(_catalog('saved'));
    final never = Completer<http.Response>();
    final watch = Stopwatch()..start();
    final songs =
        await _repo(MockClient((_) => never.future), cache).fetchAll();
    watch.stop();
    expect(songs.single.id, 'saved');
    expect(watch.elapsedMilliseconds, lessThan(350));
  });

  test('no saved catalog and CDN down: empty, so the old fallback runs',
      () async {
    final songs = await _repo(
      MockClient((_) async => throw const SocketLikeException()),
      MemoryCatalogCache(),
    ).fetchAll();
    expect(songs, isEmpty);
  });

  test('a cache that throws never breaks loading', () async {
    final songs = await _repo(
      MockClient((_) async => http.Response(_catalog('new'), 200)),
      _ThrowingCache(),
    ).fetchAll();
    expect(songs.single.id, 'new');
  });
}

class SocketLikeException implements Exception {
  const SocketLikeException();
}

class _ThrowingCache implements CatalogCache {
  @override
  Future<String?> read() async => throw StateError('disk');
  @override
  Future<void> write(String body) async => throw StateError('disk full');
}
