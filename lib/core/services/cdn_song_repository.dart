import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:visionmusicapp/core/services/song_repository.dart';
import 'package:visionmusicapp/song.dart';

/// Songs published to the Vision Music CDN (Cloudflare R2 behind
/// https://cdn.visionmusic.et/).
///
/// The backend publisher (visionmusic-backend/publisher) writes one
/// `catalog.json` listing every approved song. Only approved songs ever reach
/// the CDN: the CDN Worker serves `catalog.json` and `songs/...` and nothing
/// from staging, so this repository needs no approval checks of its own.
///
/// catalog.json shape (schemaVersion 1):
/// ```
/// {
///   "schemaVersion": 1,
///   "songs": [{
///     "id": "yosan-getahun-3obsa", "title": "3Obsa", "artist": "Yosan Getahun",
///     "language": "om", "durationMs": 313652, "publishedAt": "...",
///     "renditions": {
///       "aac64":  {"path": "songs/<id>/<version>/aac64.m4a",  "kbps": 64},
///       "aac128": {"path": "songs/<id>/<version>/aac128.m4a", "kbps": 128},
///       "aac256": {"path": "songs/<id>/<version>/aac256.m4a", "kbps": 256}
///     },
///     "artworkPath": null
///   }]
/// }
/// ```
/// Paths are relative to the CDN base URL.
class CdnSongRepository implements SongRepository {
  CdnSongRepository({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 8),
  }) : _client = client ?? http.Client();

  /// e.g. `https://cdn.visionmusic.et/` (trailing slash optional).
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  /// Free listeners stream 128 kbps; 64 is the fallback. 256 is kept for
  /// Premium and is only used when nothing else exists.
  static const List<String> streamPreference = ['aac128', 'aac64', 'aac256'];

  /// Shown when a song has no artwork on the CDN yet.
  static const String placeholderCover = 'assets/images/visionlogo.jpg';

  Uri get catalogUri => _base(baseUrl).resolve('catalog.json');

  @override
  Future<List<Song>> fetchAll() async {
    try {
      final response = await _client.get(catalogUri).timeout(timeout);
      if (response.statusCode != 200) return <Song>[];
      return parseCatalog(utf8.decode(response.bodyBytes), baseUrl);
    } catch (error) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CdnSongRepository.fetchAll failed: $error');
      }
      return <Song>[];
    }
  }

  @override
  Future<Song?> fetchById(String id) async {
    final songs = await fetchAll();
    for (final song in songs) {
      if (song.id == id) return song;
    }
    return null;
  }

  /// Turns catalog.json into songs. Pure, so it is unit-tested directly.
  /// Entries without an id, title, artist or any playable rendition are
  /// skipped rather than failing the whole catalog.
  static List<Song> parseCatalog(String body, String baseUrl) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      return <Song>[];
    }
    if (decoded is! Map || decoded['songs'] is! List) return <Song>[];
    final base = _base(baseUrl);
    final songs = <Song>[];
    final seen = <String>{};
    for (final raw in decoded['songs'] as List) {
      if (raw is! Map) continue;
      final id = _text(raw['id']);
      final title = _text(raw['title']);
      final artist = _text(raw['artist']);
      if (id == null || title == null || artist == null) continue;
      if (!seen.add(id)) continue;
      final audioPath = _pickRendition(raw['renditions']);
      if (audioPath == null) continue;
      final artwork = _safeRelative(_text(raw['artworkPath']));
      final durationMs = raw['durationMs'];
      songs.add(
        Song(
          id: id,
          title: title,
          artist: artist,
          genre: 'Oromo Music',
          filePath: base.resolve(audioPath).toString(),
          imagePath:
              artwork == null ? placeholderCover : base.resolve(artwork).toString(),
          duration: durationMs is num
              ? Duration(milliseconds: durationMs.round())
              : Duration.zero,
        ),
      );
    }
    return songs;
  }

  static String? _pickRendition(Object? renditions) {
    if (renditions is! Map) return null;
    for (final key in streamPreference) {
      final r = renditions[key];
      if (r is Map) {
        final path = _safeRelative(_text(r['path']));
        if (path != null) return path;
      }
    }
    return null;
  }

  /// Only relative paths under the CDN are accepted, so a bad catalog entry
  /// can never point the player at another host.
  static String? _safeRelative(String? path) {
    if (path == null) return null;
    if (path.startsWith('/') || path.contains('..') || path.contains('://')) {
      return null;
    }
    return path;
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static Uri _base(String baseUrl) =>
      Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
}
