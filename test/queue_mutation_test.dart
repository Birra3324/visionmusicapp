import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/song.dart';
import 'fixtures/sample_songs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'removing the current track does not throw when the replacement fails to load',
    () async {
      SharedPreferences.setMockInitialValues({});
      final manager = AudioManager(initialTracks: mockSongs);
      await manager.initializePersistentState();

      // In a headless test just_audio has no platform implementation, so
      // loading a replacement source throws (MissingPluginException). The
      // removeFromQueue path must swallow that failure instead of surfacing an
      // unhandled async exception, which would fail this test.
      manager.removeFromQueue(mockSongs[0]);

      // Give the unawaited replacement-load any chance to throw.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      manager.dispose();
    },
  );

  test('removing the only remaining track clears the queue safely', () async {
    SharedPreferences.setMockInitialValues({});
    final manager = AudioManager(initialTracks: mockSongs.sublist(0, 1));
    await manager.initializePersistentState();

    manager.removeFromQueue(mockSongs[0]);

    expect(manager.currentSong, isNull);
    manager.dispose();
  });
  test(
    'queue edits never remove songs from search, library or favorites',
    () async {
      SharedPreferences.setMockInitialValues({});
      final manager = AudioManager(initialTracks: mockSongs);
      addTearDown(manager.dispose);
      await manager.initializePersistentState();
      final song = mockSongs.first;
      manager.toggleFavorite(song);
      manager.toggleSave(song);
      manager.removeFromQueue(song);
      expect(manager.queue, isNot(contains(song)));
      expect(manager.tracks, contains(song));
      expect(manager.favoriteSongs, contains(song));
      expect(manager.library, contains(song));
      await manager.setQueue([mockSongs.last]);
      expect(manager.tracks, mockSongs);
      expect(manager.queue, [mockSongs.last]);
    },
  );

  test(
    'failed audio load leaves no false current song and keeps the catalog',
    () async {
      const broken = Song(
        id: 'unavailable',
        title: 'Unavailable',
        artist: 'Test',
        filePath: '',
      );
      final manager = AudioManager(initialTracks: [broken]);
      addTearDown(manager.dispose);
      await expectLater(manager.playAtIndex(0), throwsArgumentError);
      expect(manager.currentSong, isNull);
      expect(manager.playbackError, contains('could not be played'));
      expect(manager.tracks, [broken]);
    },
  );
}
