import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:visionmusicapp/core/services/cdn_song_repository.dart';

const _base = 'https://cdn.visionmusic.et/';

String _catalog(List<Map<String, Object?>> songs) =>
    jsonEncode({'schemaVersion': 1, 'songs': songs});

Map<String, Object?> _entry({
  String id = 'yosan-getahun-3obsa',
  Map<String, Object?>? renditions,
  Object? artworkPath,
}) => {
  'id': id,
  'title': '3Obsa',
  'artist': 'Yosan Getahun',
  'durationMs': 313652,
  'renditions':
      renditions ??
      {
        'aac64': {'path': 'songs/$id/20261121T050000Z/aac64.m4a', 'kbps': 64},
        'aac128': {
          'path': 'songs/$id/20261121T050000Z/aac128.m4a',
          'kbps': 128,
        },
        'aac256': {
          'path': 'songs/$id/20261121T050000Z/aac256.m4a',
          'kbps': 256,
        },
      },
  'artworkPath': artworkPath,
};

void main() {
  group('CdnSongRepository.parseCatalog', () {
    test('maps an entry to a playable CDN song at 128 kbps', () {
      final songs = CdnSongRepository.parseCatalog(_catalog([_entry()]), _base);
      expect(songs, hasLength(1));
      final song = songs.single;
      expect(song.id, 'yosan-getahun-3obsa');
      expect(song.title, '3Obsa');
      expect(song.artist, 'Yosan Getahun');
      expect(
        song.filePath,
        'https://cdn.visionmusic.et/songs/yosan-getahun-3obsa/20261121T050000Z/aac128.m4a',
      );
      expect(song.duration, const Duration(milliseconds: 313652));
      expect(song.imagePath, CdnSongRepository.placeholderCover);
    });

    test('falls back to 64 kbps when 128 is missing', () {
      final songs = CdnSongRepository.parseCatalog(
        _catalog([
          _entry(
            renditions: {
              'aac64': {'path': 'songs/a/1/aac64.m4a'},
            },
          ),
        ]),
        'https://cdn.visionmusic.et', // no trailing slash
      );
      expect(songs.single.filePath, 'https://cdn.visionmusic.et/songs/a/1/aac64.m4a');
    });

    test('skips entries that are incomplete, duplicated or point off the CDN', () {
      final songs = CdnSongRepository.parseCatalog(
        _catalog([
          {'id': 'no-title', 'artist': 'X', 'renditions': {}},
          _entry(id: 'no-audio', renditions: {}),
          _entry(
            id: 'other-host',
            renditions: {
              'aac128': {'path': 'https://evil.example/a.m4a'},
            },
          ),
          _entry(
            id: 'escape',
            renditions: {
              'aac128': {'path': '../staging/x/aac128.m4a'},
            },
          ),
          _entry(id: 'ok'),
          _entry(id: 'ok'),
        ]),
        _base,
      );
      expect(songs.map((s) => s.id), ['ok']);
    });

    test('uses CDN artwork when present', () {
      final songs = CdnSongRepository.parseCatalog(
        _catalog([_entry(artworkPath: 'songs/x/1/cover.jpg')]),
        _base,
      );
      expect(songs.single.imagePath, 'https://cdn.visionmusic.et/songs/x/1/cover.jpg');
    });

    test('bad JSON gives an empty list', () {
      expect(CdnSongRepository.parseCatalog('not json', _base), isEmpty);
      expect(CdnSongRepository.parseCatalog('{"songs": 3}', _base), isEmpty);
    });
  });

  group('CdnSongRepository.fetchAll', () {
    test('reads catalog.json from the CDN base', () async {
      late Uri requested;
      final repo = CdnSongRepository(
        baseUrl: _base,
        client: MockClient((request) async {
          requested = request.url;
          return http.Response(_catalog([_entry()]), 200);
        }),
      );
      final songs = await repo.fetchAll();
      expect(requested.toString(), 'https://cdn.visionmusic.et/catalog.json');
      expect(songs, hasLength(1));
    });

    test('404 or network failure gives an empty list, never throws', () async {
      final notFound = CdnSongRepository(
        baseUrl: _base,
        client: MockClient((_) async => http.Response('Not found', 404)),
      );
      expect(await notFound.fetchAll(), isEmpty);
      final offline = CdnSongRepository(
        baseUrl: _base,
        client: MockClient((_) async => throw Exception('offline')),
      );
      expect(await offline.fetchAll(), isEmpty);
    });
  });
}
