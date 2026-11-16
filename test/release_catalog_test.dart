import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/catalog/bundled_catalog.dart';
import 'package:visionmusicapp/core/services/local_song_repository.dart';
import 'package:visionmusicapp/widgets/audio_catalog_empty_state.dart';
import 'fixtures/sample_songs.dart' show mockSongs;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('unverified design samples cannot enter the listener catalog', () async {
    const repository = LocalSongRepository();
    final songs = await repository.fetchAll();
    final sampleIds = mockSongs.map((song) => song.id).toSet();
    expect(songs.where((song) => sampleIds.contains(song.id)), isEmpty);
    for (final id in sampleIds) {
      expect(await repository.fetchById(id), isNull);
    }
  });

  test(
    'sample audio and artwork are absent from the built asset bundle',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      for (final sample in mockSongs) {
        expect(assets, isNot(contains(sample.filePath)));
        if (sample.imagePath != kPlaceholderCover) {
          expect(assets, isNot(contains(sample.imagePath)));
        }
      }
      expect(assets, contains('assets/images/visionlogo.jpg'));
    },
  );

  test('official videos use YouTube artwork independently of sample audio', () {
    expect(bundledVideos, isNotEmpty);
    for (final video in bundledVideos) {
      expect(video.isPlayable, isTrue);
      expect(video.youtubeId, matches(RegExp(r'^[\w-]{11}$')));
      expect(video.displayThumbnail, video.youtubeThumbnailUrl);
      expect(video.category, 'music_videos');
    }
  });

  testWidgets('empty audio catalog has a working Watch action at large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var watched = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SingleChildScrollView(
              child: AudioCatalogEmptyState(onWatch: () => watched = true),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Watch music videos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watch music videos'));
    expect(tester.takeException(), isNull);
    expect(watched, isTrue);
  });
}
