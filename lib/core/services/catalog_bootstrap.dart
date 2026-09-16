import 'package:visionmusicapp/core/services/song_repository.dart';
import 'package:visionmusicapp/song.dart';

/// Chooses local vs remote catalog without touching Firebase itself.
///
/// Extracted from app startup so the default-to-local policy can be unit
/// tested. Callers still own constructing [FirestoreSongRepository] only when
/// Firebase is actually ready.
class CatalogBootstrap {
  const CatalogBootstrap._();

  static Future<List<Song>> load({
    required bool useFirebaseCatalog,
    required bool firebaseReady,
    required bool fallbackToLocalOnEmpty,
    required SongRepository local,
    SongRepository? remote,
    List<Song> lastResort = const [],
  }) async {
    if (useFirebaseCatalog && firebaseReady && remote != null) {
      final remoteTracks = await remote.fetchAll();
      if (remoteTracks.isNotEmpty) return remoteTracks;
      if (!fallbackToLocalOnEmpty) return remoteTracks;
    }

    final localTracks = await local.fetchAll();
    if (localTracks.isNotEmpty) return localTracks;
    return List<Song>.from(lastResort);
  }
}
