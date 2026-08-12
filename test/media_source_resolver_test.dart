import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/core/services/media_source_resolver.dart';
import 'package:visionmusicapp/mock_songs.dart';

/// Media paths used to be bundled-asset-only, so `AudioManager.playAtIndex`
/// called `AudioSource.asset()` unconditionally and every artwork widget called
/// `Image.asset()`. Both silently break once the catalog is served from
/// Firestore, where `filePath` may be an https download URL or a `gs://`
/// Storage reference.
///
/// These tests pin the classification rules so that regression cannot return.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaSourceResolver.classify', () {
    test('bundled asset paths are assets', () {
      expect(
        MediaSourceResolver.classify('assets/audio/nuho_gobana.mp3'),
        MediaLocation.asset,
      );
    });

    test('bare relative paths are treated as assets', () {
      expect(
        MediaSourceResolver.classify('audio/foo.mp3'),
        MediaLocation.asset,
      );
    });

    test('http and https URLs are network', () {
      expect(
        MediaSourceResolver.classify('https://cdn.example.com/a.mp3'),
        MediaLocation.network,
      );
      expect(
        MediaSourceResolver.classify('http://cdn.example.com/a.mp3'),
        MediaLocation.network,
      );
    });

    test('scheme matching is case insensitive', () {
      expect(
        MediaSourceResolver.classify('HTTPS://cdn.example.com/a.mp3'),
        MediaLocation.network,
      );
      expect(
        MediaSourceResolver.classify('GS://bucket/a.mp3'),
        MediaLocation.storageRef,
      );
    });

    test('surrounding whitespace does not change classification', () {
      expect(
        MediaSourceResolver.classify('  https://cdn.example.com/a.mp3  '),
        MediaLocation.network,
      );
    });

    test('gs:// references are storage refs', () {
      expect(
        MediaSourceResolver.classify('gs://vision.appspot.com/audio/a.mp3'),
        MediaLocation.storageRef,
      );
    });

    test('absolute and file:// paths are files', () {
      expect(
        MediaSourceResolver.classify('/var/mobile/downloads/a.mp3'),
        MediaLocation.file,
      );
      expect(
        MediaSourceResolver.classify('file:///var/mobile/a.mp3'),
        MediaLocation.file,
      );
    });

    test('null, empty, and whitespace-only paths are unknown', () {
      expect(MediaSourceResolver.classify(null), MediaLocation.unknown);
      expect(MediaSourceResolver.classify(''), MediaLocation.unknown);
      expect(MediaSourceResolver.classify('   '), MediaLocation.unknown);
    });

    test('a scheme with no host or bucket is unknown, not network', () {
      expect(MediaSourceResolver.classify('https://'), MediaLocation.unknown);
      expect(MediaSourceResolver.classify('gs://'), MediaLocation.unknown);
    });
  });

  group('MediaSourceResolver.isRemote', () {
    test('network and storage refs are remote', () {
      expect(MediaSourceResolver.isRemote('https://x.com/a.mp3'), isTrue);
      expect(MediaSourceResolver.isRemote('gs://bucket/a.mp3'), isTrue);
    });

    test('assets, files, and unusable paths are not remote', () {
      expect(MediaSourceResolver.isRemote('assets/audio/a.mp3'), isFalse);
      expect(MediaSourceResolver.isRemote('/tmp/a.mp3'), isFalse);
      expect(MediaSourceResolver.isRemote(null), isFalse);
    });
  });

  group('MediaSourceResolver.artwork', () {
    test('asset paths produce an AssetImage pointing at that asset', () {
      final provider = MediaSourceResolver.artwork('assets/images/a.jpg');
      expect(provider, isA<AssetImage>());
      expect((provider as AssetImage).assetName, 'assets/images/a.jpg');
    });

    test('https paths produce a NetworkImage pointing at that URL', () {
      final provider = MediaSourceResolver.artwork('https://cdn.test/a.jpg');
      expect(provider, isA<NetworkImage>());
      expect((provider as NetworkImage).url, 'https://cdn.test/a.jpg');
    });

    test('on-device file paths fall back, to keep the web build compiling', () {
      final provider = MediaSourceResolver.artwork('/tmp/a.jpg');
      expect(provider, isA<AssetImage>());
      expect(
        (provider as AssetImage).assetName,
        MediaSourceResolver.fallbackArtworkAsset,
      );
    });

    test('null falls back to the bundled logo rather than throwing', () {
      final provider = MediaSourceResolver.artwork(null);
      expect(provider, isA<AssetImage>());
      expect(
        (provider as AssetImage).assetName,
        MediaSourceResolver.fallbackArtworkAsset,
      );
    });

    test(
      'gs:// artwork falls back, because it cannot resolve synchronously',
      () {
        final provider = MediaSourceResolver.artwork('gs://bucket/a.jpg');
        expect(provider, isA<AssetImage>());
        expect(
          (provider as AssetImage).assetName,
          MediaSourceResolver.fallbackArtworkAsset,
        );
      },
    );
  });

  group('MediaSourceResolver.audioSource', () {
    test('rejects an unusable path with a descriptive error', () {
      expect(
        () => MediaSourceResolver.audioSource('   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'resolves asset and network paths without touching Firebase',
      () async {
        await expectLater(
          MediaSourceResolver.audioSource('assets/audio/a.mp3'),
          completes,
        );
        await expectLater(
          MediaSourceResolver.audioSource('https://cdn.test/a.mp3'),
          completes,
        );
      },
    );
  });

  group('bundled catalog', () {
    test('every mock song still classifies as a loadable source', () {
      for (final song in mockSongs) {
        expect(
          MediaSourceResolver.classify(song.filePath),
          isNot(MediaLocation.unknown),
          reason: '${song.id} has an unusable filePath: "${song.filePath}"',
        );
      }
    });

    test('the bundled catalog needs no network access', () {
      for (final song in mockSongs) {
        expect(
          MediaSourceResolver.isRemote(song.filePath),
          isFalse,
          reason: '${song.id} unexpectedly requires the network',
        );
      }
    });
  });
}
