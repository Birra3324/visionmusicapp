import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/playlist.dart';
import '../../settings_manager.dart';
import '../../song.dart';

class AudioManager extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final SettingsManager _settings = SettingsManager.instance;

  final List<Song> _queue = [];
  int _currentIndex = -1;

  final Set<String> _favoriteIds = {};
  final Set<String> _libraryIds = {};
  final Set<String> _downloadedIds = {};

  List<Song> get favoriteSongs =>
      _queue.where((s) => _favoriteIds.contains(s.id)).toList();

  List<Song> get library =>
      _queue.where((s) => _libraryIds.contains(s.id)).toList();

  List<Song> get recentSongs => [];
  List<Playlist> get playlists => [];

  Map<String, List<Song>> get songsByArtist {
    final map = <String, List<Song>>{};
    for (final song in _queue) {
      (map[song.artist] ??= []).add(song);
    }
    return map;
  }

  Map<String, List<Song>> get songsByAlbum {
    final map = <String, List<Song>>{};
    for (final song in _queue) {
      if (song.albumTitle != null) {
        (map[song.albumTitle!] ??= []).add(song);
      }
    }
    return map;
  }

  Song? get currentSong => (_currentIndex >= 0 && _currentIndex < _queue.length)
      ? _queue[_currentIndex]
      : null;

  List<Song> get tracks => List.unmodifiable(_queue);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get isPlayingStream =>
      _player.playerStateStream.map((s) => s.playing).distinct();

  bool get isPlaying => _player.playing;

  Stream<bool> get shuffleEnabledStream =>
      _player.shuffleModeEnabledStream.distinct();
  Stream<LoopMode> get loopModeStream => _player.loopModeStream.distinct();
  Stream<Song?> get currentSongStream =>
      _player.currentIndexStream.map((index) {
        if (index != null && index >= 0 && index < _queue.length) {
          _currentIndex = index;
          notifyListeners();
          return _queue[index];
        }
        return null;
      });

  AudioManager({List<Song>? initialTracks}) {
    if (initialTracks != null) {
      setQueue(initialTracks);
    }
    _applySettingsToPlayer();
    _settings.addListener(_applySettingsToPlayer);

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_settings.autoplay && _player.hasNext) {
          skipToNext();
        }
      }
    });

    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _currentIndex = index;
        notifyListeners();
      }
    });
  }

  void _applySettingsToPlayer() {
    _player.setShuffleModeEnabled(_settings.shuffle);
    _player.setLoopMode(_settings.repeatMode);
  }

  Future<void> setQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue
      ..clear()
      ..addAll(songs);

    if (_queue.isEmpty) {
      _currentIndex = -1;
      await _player.stop();
      notifyListeners();
      return;
    }

    _currentIndex = startIndex.clamp(0, _queue.length - 1);

    final audioSources = _queue
        .map((s) => AudioSource.asset(s.filePath))
        .toList(growable: false);

    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        initialIndex: _currentIndex,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error setting audio source: $e");
      }
    }
  }

  Future<void> playSong(Song song) async {
    final index = _queue.indexOf(song);
    if (index != -1) {
      await playAtIndex(index);
    } else {
      await setQueue([song]);
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    await _player.seek(Duration.zero, index: index);
    await _player.play();
    notifyListeners();
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void seek(Duration position) => _player.seek(position);

  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  Future<void> toggleShuffle() async {
    _settings.shuffle = !_settings.shuffle;
  }

  Future<void> cycleRepeatMode() async {
    LoopMode next = LoopMode.off;
    switch (_settings.repeatMode) {
      case LoopMode.off:
        next = LoopMode.all;
        break;
      case LoopMode.all:
        next = LoopMode.one;
        break;
      case LoopMode.one:
        next = LoopMode.off;
        break;
    }
    _settings.repeatMode = next;
  }

  Future<void> setVolume(double value) async {
    await _player.setVolume(value);
    notifyListeners();
  }

  double get volume => _player.volume;

  bool isDownloaded(Song song) => _downloadedIds.contains(song.id);
  Future<void> download(Song song) async {
    _downloadedIds.add(song.id);
    notifyListeners();
  }

  bool isSaved(Song song) => isInLibrary(song);
  void toggleSave(Song song) {
    if (isInLibrary(song)) {
      removeFromLibrary(song);
    } else {
      addToLibrary(song);
    }
  }

  bool isFavorite(Song song) => _favoriteIds.contains(song.id);
  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      _favoriteIds.remove(song.id);
    } else {
      _favoriteIds.add(song.id);
    }
    notifyListeners();
  }

  bool isInLibrary(Song song) => _libraryIds.contains(song.id);
  void addToLibrary(Song song) {
    _libraryIds.add(song.id);
    notifyListeners();
  }

  void removeFromLibrary(Song song) {
    _libraryIds.remove(song.id);
    notifyListeners();
  }

  void createPlaylist(String name) {}
  void addToQueue(Song song) {}
  void playNext(Song song) {}
  void removeFromQueue(Song song) {}
  Future<void> playFromQueueSong(Song song) async => playSong(song);

  @override
  void dispose() {
    _player.dispose();
    _settings.removeListener(_applySettingsToPlayer);
    super.dispose();
  }
}
