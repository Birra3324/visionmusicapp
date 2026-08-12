import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/mock_videos.dart';
import 'package:visionmusicapp/models/video.dart';

/// Replaces the stock Flutter counter template that shipped here, which looked
/// for a `+` button this app has never had and therefore failed on every run.
///
/// These cover the `Video` helpers that decide whether a user is sent into a
/// working player, an external browser, or a "Coming soon" state. Getting that
/// wrong is what produced "this video does not exist" errors in the app.
void main() {
  group('Video playability', () {
    test('seed placeholders are not playable', () {
      final v = Video(
        id: 't',
        title: 'T',
        artistName: 'A',
        videoUrl: 'https://www.youtube.com/watch?v=REPLACE_ALI_BIRRA_MARKATO',
      );
      expect(v.isPlaceholder, isTrue);
      expect(v.isPlayable, isFalse);
      expect(
        v.youtubeId,
        isNull,
        reason: 'a placeholder must never yield a YouTube id',
      );
    });

    test('an empty url is not playable', () {
      final v = Video(id: 't', title: 'T', artistName: 'A', videoUrl: '');
      expect(v.isPlayable, isFalse);
    });

    test('a real YouTube url is playable but not inline', () {
      final v = Video(
        id: 't',
        title: 'T',
        artistName: 'A',
        videoUrl: 'https://www.youtube.com/watch?v=8zlm6JVbi2U',
      );
      expect(v.isPlayable, isTrue);
      expect(v.isYouTube, isTrue);
      expect(
        v.isInlinePlayable,
        isFalse,
        reason: 'video_player cannot render YouTube; it must open externally',
      );
    });

    test('a direct media url is inline playable', () {
      final v = Video(
        id: 't',
        title: 'T',
        artistName: 'A',
        videoUrl: 'https://cdn.example.com/clip.mp4',
      );
      expect(v.isInlinePlayable, isTrue);
    });
  });

  group('YouTube id parsing', () {
    Video make(String url) =>
        Video(id: 't', title: 'T', artistName: 'A', videoUrl: url);

    test('watch?v= form', () {
      expect(
        make('https://www.youtube.com/watch?v=8zlm6JVbi2U').youtubeId,
        '8zlm6JVbi2U',
      );
    });

    test('youtu.be short form', () {
      expect(make('https://youtu.be/F1cfzTGxcCs').youtubeId, 'F1cfzTGxcCs');
    });

    test('shorts form', () {
      expect(
        make('https://www.youtube.com/shorts/LK0J9Au84-o').youtubeId,
        'LK0J9Au84-o',
      );
    });

    test('embed form', () {
      expect(
        make('https://www.youtube.com/embed/LK0J9Au84-o').youtubeId,
        'LK0J9Au84-o',
      );
    });

    test('extra query parameters do not break parsing', () {
      expect(
        make('https://www.youtube.com/watch?v=8zlm6JVbi2U&t=42s').youtubeId,
        '8zlm6JVbi2U',
      );
    });

    test('a non-YouTube url yields no id', () {
      expect(make('https://cdn.example.com/clip.mp4').youtubeId, isNull);
    });
  });

  group('Thumbnails', () {
    test('a YouTube video with no artwork falls back to its poster frame', () {
      final v = Video(
        id: 't',
        title: 'T',
        artistName: 'A',
        videoUrl: 'https://youtu.be/F1cfzTGxcCs',
      );
      expect(v.displayThumbnail, contains('img.youtube.com'));
      expect(v.thumbnailIsAsset, isFalse);
    });

    test('an explicit thumbnail wins over the poster frame', () {
      final v = Video(
        id: 't',
        title: 'T',
        artistName: 'A',
        videoUrl: 'https://youtu.be/F1cfzTGxcCs',
        thumbnailUrl: 'assets/images/visionlogo.jpg',
      );
      expect(v.displayThumbnail, 'assets/images/visionlogo.jpg');
      expect(v.thumbnailIsAsset, isTrue);
    });

    test('a placeholder with no artwork still resolves to something', () {
      final v = Video(
        id: 't',
        title: 'T',
        artistName: 'A',
        videoUrl: 'https://www.youtube.com/watch?v=REPLACE_X',
      );
      expect(
        v.displayThumbnail,
        isNotEmpty,
        reason: 'the UI must never be handed an empty image path',
      );
    });
  });

  group('Bundled video catalogue', () {
    test('has entries and unique ids', () {
      expect(mockVideos, isNotEmpty);
      final ids = mockVideos.map((v) => v.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate video id');
    });

    test('every entry has a title, artist and category', () {
      for (final v in mockVideos) {
        expect(v.title.trim(), isNotEmpty, reason: 'id=${v.id}');
        expect(v.artistName.trim(), isNotEmpty, reason: 'id=${v.id}');
        expect(v.category.trim(), isNotEmpty, reason: 'id=${v.id}');
      }
    });

    test('every entry resolves to a usable thumbnail', () {
      for (final v in mockVideos) {
        expect(v.displayThumbnail.trim(), isNotEmpty, reason: 'id=${v.id}');
      }
    });
  });
}
