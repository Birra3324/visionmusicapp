import '../../song.dart';

abstract class SongRepository {
  Future<List<Song>> fetchAll();
  Future<Song?> fetchById(String id);
}
