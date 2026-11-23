import 'package:just_audio/just_audio.dart';

/// Web: no file system, stream directly.
Future<AudioSource> cachedNetworkAudioSource(Uri uri) async =>
    AudioSource.uri(uri);

Future<void> pruneAudioCache({int? maxBytes}) async {}
