import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/controllers/playlist_controller.dart';
import 'package:visionmusicapp/models/playlist.dart';
import 'package:visionmusicapp/song.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const a = Song(id: 'real-a', title: 'A', artist: 'Artist', filePath: 'a.mp3');
  const b = Song(id: 'real-b', title: 'B', artist: 'Artist', filePath: 'b.mp3');

  test('legacy sample positions never attach unrelated replacement songs', () {
    final manager = AudioManager(initialTracks: [a, b]);
    addTearDown(manager.dispose);
    final controller = PlaylistController(audioManager: manager);
    addTearDown(controller.dispose);
    final legacy = Playlist.fromJson({
      'id': 'old',
      'name': 'My playlist',
      'trackIndices': [0, 1],
    });
    expect(controller.songsForPlaylist(legacy), isEmpty);
    final saved = legacy.copyWith(name: 'Preserved').toJson();
    expect(saved['trackIndices'], [0, 1]);
    expect(saved['name'], 'Preserved');
  });

  test(
    'saved playlist keeps song identity across catalog reordering and removal',
    () async {
      SharedPreferences.setMockInitialValues({});
      final first = AudioManager(initialTracks: [a, b]);
      addTearDown(first.dispose);
      final writer = PlaylistController(audioManager: first);
      addTearDown(writer.dispose);
      await writer.createPlaylist('Favorites');
      await writer.addSongToPlaylist(writer.playlists.single, a);
      await writer.addSongToPlaylist(writer.playlists.single, b);

      final reordered = AudioManager(initialTracks: [b, a]);
      addTearDown(reordered.dispose);
      final reader = PlaylistController(audioManager: reordered);
      addTearDown(reader.dispose);
      await reader.load();
      expect(reader.songsForPlaylist(reader.playlists.single), [a, b]);

      final reduced = AudioManager(initialTracks: [b]);
      addTearDown(reduced.dispose);
      final reducedReader = PlaylistController(audioManager: reduced);
      addTearDown(reducedReader.dispose);
      await reducedReader.load();
      expect(reducedReader.songsForPlaylist(reducedReader.playlists.single), [
        b,
      ]);
      expect(reducedReader.playlists.single.trackIds, ['real-a', 'real-b']);
    },
  );
}
