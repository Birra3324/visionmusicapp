import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/core/services/catalog_bootstrap.dart';
import 'package:visionmusicapp/core/services/song_repository.dart';
import 'package:visionmusicapp/song.dart';

class _MemRepo implements SongRepository {
  _MemRepo(this.songs);
  final List<Song> songs;

  @override
  Future<List<Song>> fetchAll() async => List<Song>.from(songs);

  @override
  Future<Song?> fetchById(String id) async {
    for (final song in songs) {
      if (song.id == id) return song;
    }
    return null;
  }
}

Song _song(String id) =>
    Song(id: id, title: id, artist: 'A', filePath: 'assets/audio/$id.mp3');

void main() {
  final localSongs = [_song('local')];
  final remoteSongs = [_song('remote')];
  final lastResort = [_song('fallback')];

  test('defaults to the local catalog when Firebase catalog is off', () async {
    final tracks = await CatalogBootstrap.load(
      useFirebaseCatalog: false,
      firebaseReady: true,
      fallbackToLocalOnEmpty: true,
      local: _MemRepo(localSongs),
      remote: _MemRepo(remoteSongs),
      lastResort: lastResort,
    );
    expect(tracks.map((s) => s.id), ['local']);
  });

  test('uses remote catalog when the flag is on and Firebase is ready', () async {
    final tracks = await CatalogBootstrap.load(
      useFirebaseCatalog: true,
      firebaseReady: true,
      fallbackToLocalOnEmpty: true,
      local: _MemRepo(localSongs),
      remote: _MemRepo(remoteSongs),
      lastResort: lastResort,
    );
    expect(tracks.map((s) => s.id), ['remote']);
  });

  test('falls back to local when remote is empty', () async {
    final tracks = await CatalogBootstrap.load(
      useFirebaseCatalog: true,
      firebaseReady: true,
      fallbackToLocalOnEmpty: true,
      local: _MemRepo(localSongs),
      remote: _MemRepo(const []),
      lastResort: lastResort,
    );
    expect(tracks.map((s) => s.id), ['local']);
  });

  test('returns empty remote when fallback is disabled', () async {
    final tracks = await CatalogBootstrap.load(
      useFirebaseCatalog: true,
      firebaseReady: true,
      fallbackToLocalOnEmpty: false,
      local: _MemRepo(localSongs),
      remote: _MemRepo(const []),
      lastResort: lastResort,
    );
    expect(tracks, isEmpty);
  });

  test('skips remote when Firebase is not ready', () async {
    final tracks = await CatalogBootstrap.load(
      useFirebaseCatalog: true,
      firebaseReady: false,
      fallbackToLocalOnEmpty: true,
      local: _MemRepo(localSongs),
      remote: _MemRepo(remoteSongs),
      lastResort: lastResort,
    );
    expect(tracks.map((s) => s.id), ['local']);
  });

  test('uses lastResort when local catalog is empty', () async {
    final tracks = await CatalogBootstrap.load(
      useFirebaseCatalog: false,
      firebaseReady: false,
      fallbackToLocalOnEmpty: true,
      local: _MemRepo(const []),
      lastResort: lastResort,
    );
    expect(tracks.map((s) => s.id), ['fallback']);
  });
}
