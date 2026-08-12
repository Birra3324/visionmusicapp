import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio_manager.dart';
import '../models/playlist.dart';
import '../song.dart';

class PlaylistController extends ChangeNotifier {
  static const _prefsKey = 'vision_playlists_v1';

  final AudioManager audioManager;

  List<Playlist> _playlists = [];
  List<Playlist> get playlists => List.unmodifiable(_playlists);

  PlaylistController({required this.audioManager});

  Future<void> load() async {
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
        debugPrint('Corrupt payload was: $jsonString');
        _playlists = [];
      }
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _playlists.map((p) => p.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  Future<void> createPlaylist(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = Playlist(id: id, name: name, trackIndices: []);
    _playlists = [..._playlists, playlist];
    await _save();
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    _playlists = _playlists
        .map((p) => p.id == id ? p.copyWith(name: newName) : p)
        .toList();
    await _save();
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists = _playlists.where((p) => p.id != id).toList();
    await _save();
    notifyListeners();
  }

  Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    final tracks = audioManager.tracks;
    final index = tracks.indexOf(song);
    if (index == -1) return;

    final updatedIndices = List<int>.from(playlist.trackIndices)..add(index);
    _updatePlaylist(playlist.copyWith(trackIndices: updatedIndices));
    await _save();
    notifyListeners();
  }

  Future<void> removeSongFromPlaylist(Playlist playlist, int trackIndex) async {
    final updatedIndices = List<int>.from(playlist.trackIndices)
      ..remove(trackIndex);
    _updatePlaylist(playlist.copyWith(trackIndices: updatedIndices));
    await _save();
    notifyListeners();
  }

  void _updatePlaylist(Playlist updated) {
    _playlists = _playlists
        .map((p) => p.id == updated.id ? updated : p)
        .toList();
  }

  List<Song> songsForPlaylist(Playlist playlist) {
    final tracks = audioManager.tracks;
    return playlist.trackIndices
        .where((i) => i >= 0 && i < tracks.length)
        .map((i) => tracks[i])
        .toList();
  }
}
