import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/core/services/public_catalog_policy.dart';

void main() {
  group('PublicCatalogPolicy', () {
    test('rejects draft, processing and unapproved tracks', () {
      for (final data in [
        {'status': 'draft', 'approved': true},
        {'status': 'processing', 'approved': true},
        {'status': 'published', 'approved': false},
        {'status': 'published'},
      ]) {
        expect(PublicCatalogPolicy.isPublishedAndApproved(data), isFalse);
        expect(PublicCatalogPolicy.approvedAudioPath(data), isNull);
      }
    });

    test('prefers an approved public high-quality rendition', () {
      final result = PublicCatalogPolicy.approvedAudioPath({
        'status': 'published',
        'approved': true,
        'renditions': {
          'aac256': {
            'url': 'https://cdn.visionmusic.et/song/256.aac',
            'approved': true,
            'public': true,
          },
          'aac128': {
            'url': 'https://cdn.visionmusic.et/song/128.aac',
            'approved': true,
            'public': true,
          },
        },
      });
      expect(result, endsWith('/256.aac'));
    });

    test('skips a broken legacy Firebase URL for a playable rendition', () {
      const playable =
          'https://firebasestorage.googleapis.com/v0/b/visionmusic.firebasestorage.app'
          '/o/public%2Frenditions%2Ftrack%2Faac256.m4a?alt=media';
      final data = <String, dynamic>{
        'status': 'published',
        'approved': true,
        'publishedAudioUrl':
            'https://firebasestorage.googleapis.com/renditions/track/aac256.m4a',
      };
      expect(PublicCatalogPolicy.approvedAudioPath(data), isNull);
      data['renditions'] = {
        'aac256': {'url': playable, 'approved': true, 'public': true},
      };
      expect(PublicCatalogPolicy.approvedAudioPath(data), playable);
    });

    test('rejects local paths and private renditions', () {
      expect(
        PublicCatalogPolicy.approvedAudioPath({
          'status': 'published',
          'approved': true,
          'filePath': 'assets/audio/private.mp3',
          'renditions': {
            'aac128': {
              'url': 'https://cdn.visionmusic.et/private.aac',
              'approved': true,
              'public': false,
            },
          },
        }),
        isNull,
      );
    });
  });
}
