import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/catalog/bundled_catalog.dart';
import 'package:visionmusicapp/core/services/local_song_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'three selected recordings resolve to distinct bundled assets',
    () async {
      const repository = LocalSongRepository();
      final tracks = await repository.fetchAll();
      expect(tracks, hasLength(3));
      expect(tracks.map((s) => s.id).toSet(), hasLength(3));
      expect(tracks.map((s) => s.filePath).toSet(), hasLength(3));
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      expect(
        assets.where((p) => p.startsWith('assets/local_review/')),
        isEmpty,
      );
      expect(
        assets.where((p) => p.startsWith('assets/release_audio/')).toSet(),
        {
          'assets/release_audio/gumgume.mp3',
          'assets/release_audio/qondaala.m4a',
          'assets/release_audio/shilimii.m4a',
        },
      );
      for (final track in tracks) {
        expect(track.duration, greaterThan(Duration.zero));
        expect(assets, contains(track.filePath));
        expect(
          (await rootBundle.load(track.filePath)).lengthInBytes,
          greaterThan(1000000),
        );
        expect(await repository.fetchById(track.id), track);
      }
      expect(
        assets,
        isNot(contains('assets/local_review/preview_d61d08a9.mp3')),
      );
      expect(
        assets,
        isNot(contains('assets/local_review/preview_a8b38af1.mp3')),
      );
      expect(
        assets,
        isNot(contains('assets/local_review/preview_302664d7.mp3')),
      );
      expect(tracks.map((s) => s.title), contains('Shilimii'));
      expect(tracks.map((s) => s.title).toSet(), {
        'Gumgume',
        'Qondaala',
        'Shilimii',
      });
      expect(tracks, bundledSongs);
    },
  );
}
