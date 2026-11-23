// LockCachingAudioSource is marked experimental in just_audio; the app uses it on purpose.
// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:visionmusicapp/core/services/audio_cache/audio_cache.dart';
import 'package:visionmusicapp/core/services/audio_cache/audio_cache_io.dart'
    as io;

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('vm_audio_cache_');
    io.debugAudioCacheDirectory = dir;
    io.debugAudioCacheEnabled = true;
  });

  tearDown(() {
    io.debugAudioCacheDirectory = null;
    io.debugAudioCacheEnabled = null;
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('CDN songs get a caching source with a stable file per URL', () async {
    final uri = Uri.parse(
      'https://cdn.visionmusic.et/songs/yosan-getahun-3obsa/1/aac128.m4a',
    );
    final a = await cachedNetworkAudioSource(uri);
    final b = await cachedNetworkAudioSource(uri);
    expect(a, isA<LockCachingAudioSource>());
    final fa = (a as LockCachingAudioSource).cacheFile;
    final fb = (b as LockCachingAudioSource).cacheFile;
    expect(await fa, isA<File>());
    expect((await fa).path, (await fb).path);
    expect((await fa).path, startsWith(dir.path));
    expect((await fa).path, endsWith('.m4a'));
  });

  test('a new song version gets a different file', () {
    expect(
      audioCacheKey('https://cdn.visionmusic.et/songs/x/1/aac128.m4a'),
      isNot(audioCacheKey('https://cdn.visionmusic.et/songs/x/2/aac128.m4a')),
    );
  });

  test('where caching is off (iPhone, web) songs stream as before', () async {
    io.debugAudioCacheEnabled = false;
    final source = await cachedNetworkAudioSource(
      Uri.parse('https://cdn.visionmusic.et/songs/x/1/aac128.m4a'),
    );
    expect(source, isNot(isA<LockCachingAudioSource>()));
    expect(source, isA<UriAudioSource>());
  });

  test('pruning removes the oldest songs until under the limit', () async {
    final now = DateTime.now();
    for (var i = 0; i < 5; i++) {
      final f = File('${dir.path}/song$i.m4a')
        ..writeAsBytesSync(List.filled(100, 0));
      f.setLastModifiedSync(now.subtract(Duration(days: 5 - i)));
    }
    await pruneAudioCache(maxBytes: 250);
    final left = dir.listSync().map((e) => e.uri.pathSegments.last).toList()
      ..sort();
    expect(left, ['song3.m4a', 'song4.m4a']);
  });

  test('pruning under the limit keeps everything', () async {
    File('${dir.path}/a.m4a').writeAsBytesSync(List.filled(10, 0));
    await pruneAudioCache(maxBytes: 1000);
    expect(dir.listSync(), hasLength(1));
  });
}
