import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visionmusicapp/core/services/audio_cache/audio_cache.dart'
    show audioCacheKey, audioCacheMaxBytes;

/// Overrides the cache folder and platform check in tests.
@visibleForTesting
Directory? debugAudioCacheDirectory;
@visibleForTesting
bool? debugAudioCacheEnabled;

bool get _enabled =>
    debugAudioCacheEnabled ??
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

Future<Directory?> _cacheDirectory() async {
  if (debugAudioCacheDirectory != null) return debugAudioCacheDirectory;
  try {
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/vision_audio_cache');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  } catch (_) {
    return null;
  }
}

/// Audio source for a song on the CDN: cached on Android, streamed elsewhere.
/// Falls back to plain streaming if the cache folder isn't available.
Future<AudioSource> cachedNetworkAudioSource(Uri uri) async {
  if (!_enabled || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return AudioSource.uri(uri);
  }
  final dir = await _cacheDirectory();
  if (dir == null) return AudioSource.uri(uri);
  final ext = _extension(uri);
  final file = File('${dir.path}/${audioCacheKey(uri.toString())}$ext');
  // ignore: experimental_member_use
  return LockCachingAudioSource(uri, cacheFile: file);
}

String _extension(Uri uri) {
  final last = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
  final dot = last.lastIndexOf('.');
  if (dot < 0) return '';
  final ext = last.substring(dot).toLowerCase();
  return RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(ext) ? ext : '';
}

/// Deletes the least recently used saved songs until the folder is under
/// [maxBytes]. Never throws: a cache problem must not stop the app.
Future<void> pruneAudioCache({int? maxBytes}) async {
  if (!_enabled) return;
  try {
    final dir = await _cacheDirectory();
    if (dir == null || !dir.existsSync()) return;
    final limit = maxBytes ?? audioCacheMaxBytes;
    final files = dir.listSync().whereType<File>().map((f) {
      final stat = f.statSync();
      return (file: f, size: stat.size, modified: stat.modified);
    }).toList()
      ..sort((a, b) => a.modified.compareTo(b.modified));
    var total = files.fold<int>(0, (sum, f) => sum + f.size);
    for (final entry in files) {
      if (total <= limit) break;
      try {
        entry.file.deleteSync();
        total -= entry.size;
      } catch (_) {}
    }
  } catch (_) {}
}
