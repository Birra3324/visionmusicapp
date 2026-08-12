import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

/// Where a `Song.filePath` / `Song.imagePath` actually lives.
enum MediaLocation {
  /// Bundled with the app, e.g. `assets/audio/nuho_gobana.mp3`.
  asset,

  /// Reachable over http(s), e.g. a Firebase Storage download URL or a CDN URL.
  network,

  /// A Firebase Storage `gs://bucket/path` reference. Must be exchanged for a
  /// download URL before it can be fetched, which requires Firebase to be
  /// initialised.
  storageRef,

  /// An on-device absolute path or `file://` URI, used for downloaded tracks.
  file,

  /// Empty, blank, or otherwise unusable.
  unknown,
}

/// Resolves a stored media path to something the player and the image system
/// can actually load.
///
/// The catalog used to be bundled-assets-only, so `AudioManager` called
/// `AudioSource.asset()` unconditionally and every artwork widget called
/// `Image.asset()`. Both break the moment the catalog is served from Firestore,
/// where `filePath` is documented as "Storage URL or asset path". This class is
/// the single place that decides which loader applies.
class MediaSourceResolver {
  const MediaSourceResolver._();

  /// Artwork shown when a song has no usable [Song.imagePath].
  static const String fallbackArtworkAsset = 'assets/images/visionlogo.jpg';

  /// Classifies [path] without touching the network or Firebase.
  ///
  /// Pure and synchronous, so it is fully unit-testable.
  static MediaLocation classify(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) return MediaLocation.unknown;

    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      // Reject a bare scheme with no host, e.g. "https://".
      final uri = Uri.tryParse(value);
      if (uri == null || uri.host.isEmpty) return MediaLocation.unknown;
      return MediaLocation.network;
    }
    if (lower.startsWith('gs://')) {
      // Reject "gs://" with no bucket.
      if (value.length <= 'gs://'.length) return MediaLocation.unknown;
      return MediaLocation.storageRef;
    }
    if (lower.startsWith('file://') || value.startsWith('/')) {
      return MediaLocation.file;
    }
    if (lower.startsWith('assets/')) return MediaLocation.asset;

    // Anything else is treated as a relative asset path. This keeps older
    // catalog entries working if they omitted the `assets/` prefix.
    return MediaLocation.asset;
  }

  /// True when loading [path] requires network access.
  static bool isRemote(String? path) {
    final location = classify(path);
    return location == MediaLocation.network ||
        location == MediaLocation.storageRef;
  }

  /// Converts a `gs://` reference into a fetchable https download URL.
  ///
  /// Throws [StateError] with an actionable message if Firebase Storage is not
  /// available, rather than surfacing a raw plugin exception to the player.
  static Future<Uri> resolveStorageRef(String path) async {
    try {
      final url = await FirebaseStorage.instance
          .refFromURL(path.trim())
          .getDownloadURL();
      return Uri.parse(url);
    } catch (e) {
      throw StateError(
        'Could not resolve Firebase Storage reference "$path". '
        'Check that Firebase is configured and Storage rules allow read. '
        'Underlying error: $e',
      );
    }
  }

  /// Builds the [AudioSource] for [path].
  ///
  /// Async because a `gs://` reference has to be exchanged for a download URL
  /// first. Asset, network, and file paths resolve without any I/O.
  static Future<AudioSource> audioSource(String path) async {
    final value = path.trim();
    switch (classify(value)) {
      case MediaLocation.asset:
        return AudioSource.asset(value);
      case MediaLocation.network:
        return AudioSource.uri(Uri.parse(value));
      case MediaLocation.storageRef:
        return AudioSource.uri(await resolveStorageRef(value));
      case MediaLocation.file:
        final normalised = value.toLowerCase().startsWith('file://')
            ? Uri.parse(value).toFilePath()
            : value;
        return AudioSource.file(normalised);
      case MediaLocation.unknown:
        throw ArgumentError.value(
          path,
          'path',
          'Song has no usable audio path',
        );
    }
  }

  /// Builds the [ImageProvider] for [path], falling back to the bundled logo
  /// when the path is missing or unusable.
  ///
  /// `gs://` artwork is *not* resolvable synchronously, so it also falls back.
  /// Store https download URLs in `imagePath` rather than `gs://` references.
  ///
  /// On-device file artwork also falls back, deliberately: supporting it needs
  /// `FileImage` and therefore `dart:io`, which would break the web build. No
  /// artwork is ever written to disk today — "downloaded" is currently only a
  /// flag in SharedPreferences — so this costs nothing. Revisit if real offline
  /// downloads land.
  static ImageProvider artwork(String? path) {
    final value = path?.trim() ?? '';
    switch (classify(value)) {
      case MediaLocation.asset:
        return AssetImage(value);
      case MediaLocation.network:
        return NetworkImage(value);
      case MediaLocation.file:
      case MediaLocation.storageRef:
      case MediaLocation.unknown:
        return const AssetImage(fallbackArtworkAsset);
    }
  }
}
