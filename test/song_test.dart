import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/mock_songs.dart';
import 'package:visionmusicapp/song.dart';

/// `Song` equality is load-bearing, not cosmetic.
///
/// `AudioManager` uses `_queue.indexOf(song)` and `_queue.contains(song)`.
/// While the catalogue is the compile-time `const mockSongs` list, Dart
/// canonicalises identical const instances and reference equality happens to
/// work. The moment songs arrive from Firestore they become fresh non-const
/// objects — `indexOf` returns -1, `playSong` falls through to
/// `setQueue([song])`, and the user's queue is destroyed on every tap.
///
/// These tests exist to catch that regression before it ships.
void main() {
  group('Song equality', () {
    test('two songs with the same id are equal even when built separately', () {
      const a = Song(id: 'x', title: 'A', artist: 'B', filePath: 'p.mp3');
      final b = Song(
        id: 'x',
        title: 'Different title',
        artist: 'Different artist',
        filePath: 'other.mp3',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different ids are not equal', () {
      const a = Song(id: 'x', title: 'A', artist: 'B', filePath: 'p.mp3');
      const b = Song(id: 'y', title: 'A', artist: 'B', filePath: 'p.mp3');
      expect(a, isNot(equals(b)));
    });

    test('indexOf finds a non-const copy — the Firestore failure mode', () {
      final queue = <Song>[
        const Song(id: 'one', title: '1', artist: 'A', filePath: '1.mp3'),
        const Song(id: 'two', title: '2', artist: 'B', filePath: '2.mp3'),
      ];
      // Simulates a song rebuilt from a Firestore document.
      final fromRemote = Song(
        id: 'two',
        title: '2',
        artist: 'B',
        filePath: '2.mp3',
      );

      expect(
        queue.indexOf(fromRemote),
        1,
        reason: 'indexOf must match on id, or playSong wipes the queue',
      );
      expect(queue.contains(fromRemote), isTrue);
    });

    test('works as a Set and Map key', () {
      final set = <Song>{
        const Song(id: 'a', title: 'A', artist: 'X', filePath: 'a.mp3'),
        Song(id: 'a', title: 'A duplicate', artist: 'Y', filePath: 'b.mp3'),
      };
      expect(set.length, 1, reason: 'same id must collapse to one entry');
    });
  });

  group('Bundled catalogue integrity', () {
    test('has songs', () {
      expect(mockSongs, isNotEmpty);
    });

    test('every id is unique', () {
      final ids = mockSongs.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate song id');
    });

    test('every song has a title, artist and file path', () {
      for (final song in mockSongs) {
        expect(song.title.trim(), isNotEmpty, reason: 'id=${song.id}');
        expect(song.artist.trim(), isNotEmpty, reason: 'id=${song.id}');
        expect(song.filePath.trim(), isNotEmpty, reason: 'id=${song.id}');
      }
    });

    test('every audio path points inside assets/audio', () {
      for (final song in mockSongs) {
        expect(
          song.filePath,
          startsWith('assets/audio/'),
          reason: 'id=${song.id}',
        );
      }
    });

    test('no song references the mislabelled lagaa.mp3', () {
      // It was an AAC/M4A file with a .mp3 extension, which is what produced
      // AVFoundation -11849 on macOS. Renamed to .m4a; nothing should point at
      // the old name again.
      for (final song in mockSongs) {
        expect(
          song.filePath,
          isNot(endsWith('/lagaa.mp3')),
          reason: 'id=${song.id} references the container-mismatched file',
        );
      }
    });

    test('every song has a real duration', () {
      // Zero durations leave the lock-screen scrubber unusable.
      for (final song in mockSongs) {
        expect(
          song.duration,
          greaterThan(Duration.zero),
          reason: 'id=${song.id} has no duration',
        );
      }
    });
  });
}
