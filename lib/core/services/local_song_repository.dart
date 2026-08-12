import 'package:visionmusicapp/core/services/song_repository.dart';
import 'package:visionmusicapp/mock_songs.dart';
import 'package:visionmusicapp/song.dart';

/// Repository backed by the bundled `mockSongs` list in `lib/mock_songs.dart`.
class LocalSongRepository implements SongRepository {
  const LocalSongRepository();

  @override
  Future<List<Song>> fetchAll() async => List<Song>.from(mockSongs);

  @override
  Future<Song?> fetchById(String id) async {
    try {
      return mockSongs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
