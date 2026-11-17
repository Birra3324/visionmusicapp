import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio_manager.dart';
import '../models/playlist.dart';
import '../song.dart';

class PlaylistController extends ChangeNotifier {
  static const _prefsKey = 'vision_playlists_v1';
  static int _nextId = 0;
  static Future<void>? _pendingWrite;
  bool _disposed = false;

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  final AudioManager audioManager;

  List<Playlist> _playlists = [];
  List<Playlist> get playlists => List.unmodifiable(_playlists);

  PlaylistController({required this.audioManager});

  Future<void> load({bool notify = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);

    if (jsonString != null) {
      try {
        final list = jsonDecode(jsonString) as List<dynamic>;
        _playlists = list
            .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // This is data loss, so it must never be silent. Corrupt or
        // schema-changed JSON previously wiped every saved playlist with no
        // trace at all — the user simply found them gone. The raw payload is
        // kept so a future migration can attempt recovery rather than
        // discarding it.
        debugPrint('Playlist store unreadable, starting empty: $e');
        _playlists = [];
      }
    }

    if (notify) _notifyIfActive();
  }

  // Dialogs and open playlist screens can hold separate controllers. Serialize
  // read-modify-write operations and refresh before each edit, so stale screens
  // cannot overwrite a song added elsewhere. A failed write must not block later edits.
  Future<T> _edit<T>(T Function() change) {
    late final Future<void> completion;
    final operation = (_pendingWrite ?? Future<void>.value()).then((_) async {
      try {
        await load(notify: false);
        final result = change();
        await _save();
        _notifyIfActive();
        return result;
      } finally {
        if (identical(_pendingWrite, completion)) _pendingWrite = null;
      }
    });
    completion = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    _pendingWrite = completion;
    return operation;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _playlists.map((p) => p.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  Future<Playlist> createPlaylist(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('Playlist name cannot be empty');
    return _edit(() {
      final id = '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';
      final playlist = Playlist(id: id, name: cleanName, trackIds: []);
      _playlists = [..._playlists, playlist];
      return playlist;
    });
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final cleanName = newName.trim();
    if (cleanName.isEmpty) throw ArgumentError('Playlist name cannot be empty');
    await _edit(() {
      _playlists = _playlists
          .map((p) => p.id == id ? p.copyWith(name: cleanName) : p)
          .toList();
    });
  }

  Future<void> deletePlaylist(String id) => _edit(() {
    _playlists = _playlists.where((p) => p.id != id).toList();
  });

  Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    if (!audioManager.tracks.any((track) => track.id == song.id)) return;
    await _edit(() {
      final index = _playlists.indexWhere((p) => p.id == playlist.id);
      if (index == -1) return;
      final current = _playlists[index];
      if (current.trackIds.contains(song.id)) return;
      _updatePlaylist(
        current.copyWith(trackIds: [...current.trackIds, song.id]),
      );
    });
  }

  Future<void> removeSongFromPlaylist(Playlist playlist, String songId) =>
      _edit(() {
        final index = _playlists.indexWhere((p) => p.id == playlist.id);
        if (index == -1) return;
        final current = _playlists[index];
        _updatePlaylist(
          current.copyWith(
            trackIds: current.trackIds.where((id) => id != songId).toList(),
          ),
        );
      });

  void _updatePlaylist(Playlist updated) {
    _playlists = _playlists
        .map((p) => p.id == updated.id ? updated : p)
        .toList();
  }

  List<Song> songsForPlaylist(Playlist playlist) {
    final byId = {for (final song in audioManager.tracks) song.id: song};
    return playlist.trackIds.map((id) => byId[id]).whereType<Song>().toList();
  }
}
