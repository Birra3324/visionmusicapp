import 'package:visionmusicapp/core/services/song_repository.dart';
import 'package:visionmusicapp/catalog/bundled_catalog.dart';
import 'package:visionmusicapp/song.dart';

/// Repository backed by the bundled curated audio catalog.
class LocalSongRepository implements SongRepository {
  const LocalSongRepository();

  @override
  Future<List<Song>> fetchAll() async => List<Song>.from(bundledSongs);

  @override
  Future<Song?> fetchById(String id) async {
    try {
      return bundledSongs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
