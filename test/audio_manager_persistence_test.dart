import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/mock_songs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('favorites, library and offline state survive a new manager', () async {
    SharedPreferences.setMockInitialValues({});
    final first = AudioManager(initialTracks: mockSongs);
    await first.initializePersistentState();

    final song = mockSongs.first;
    first.toggleFavorite(song);
    first.toggleSave(song);
    await first.download(song);
    await Future<void>.delayed(Duration.zero);

    final second = AudioManager(initialTracks: mockSongs);
    await second.initializePersistentState();

    expect(second.isFavorite(song), isTrue);
    expect(second.isSaved(song), isTrue);
    expect(second.isDownloaded(song), isTrue);

    first.dispose();
    second.dispose();
  });

  test(
    'recent ids restore in their saved order and ignore missing songs',
    () async {
      SharedPreferences.setMockInitialValues({
        'audio.recentIds': [mockSongs[1].id, 'removed-song', mockSongs[0].id],
      });
      final manager = AudioManager(initialTracks: mockSongs);
      await manager.initializePersistentState();

      expect(manager.recentSongs.map((song) => song.id), [
        mockSongs[1].id,
        mockSongs[0].id,
      ]);
      manager.dispose();
    },
  );
}
