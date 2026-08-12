import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/mock_songs.dart';

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
}
