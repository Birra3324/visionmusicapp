import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/core/services/media_source_resolver.dart';
import 'package:visionmusicapp/core/services/app_observability.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/models/playlist.dart';

class AudioManager extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final SettingsManager _settings = SettingsManager.instance;

  final List<Song> _queue = [];
  int _currentIndex = -1;

  /// Recently played, most recent first. Capped at [_recentLimit].
  static const int _recentLimit = 40;
  final List<Song> _recent = [];

  AudioPlayer get player => _player;

  // In-memory state for UI
  final Set<String> _favoriteIds = {};
  final Set<String> _libraryIds = {};
  final Set<String> _downloadedIds = {};
  SharedPreferences? _prefs;

  static const _favoriteIdsKey = 'audio.favoriteIds';
  static const _libraryIdsKey = 'audio.libraryIds';
  static const _downloadedIdsKey = 'audio.downloadedIds';
  static const _recentIdsKey = 'audio.recentIds';

  List<Song> get favoriteSongs =>
      _queue.where((s) => _favoriteIds.contains(s.id)).toList();

  List<Song> get library =>
      _queue.where((s) => _libraryIds.contains(s.id)).toList();

  List<Song> get recentSongs => List.unmodifiable(_recent);
  List<Playlist> get playlists => const [];

  Song? get currentSong => (_currentIndex >= 0 && _currentIndex < _queue.length)
      ? _queue[_currentIndex]
      : null;

  List<Song> get tracks => List.unmodifiable(_queue);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<double> get speedStream => _player.speedStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get isPlayingStream =>
      _player.playerStateStream.map((s) => s.playing).distinct();

  bool get isPlaying => _player.playing;

  /// Shuffle and repeat are decided here, not by the player.
  ///
  /// Because [playAtIndex] loads one [AudioSource] at a time, the player's own
  /// shuffle and loop settings operate on a list of exactly one track: shuffle
  /// was a no-op and repeat-all looped the same song forever. Both now read
  /// from [SettingsManager], which is the single source of truth.
  final StreamController<bool> _shuffleController =
      StreamController<bool>.broadcast();
  final StreamController<LoopMode> _loopController =
      StreamController<LoopMode>.broadcast();

  Stream<bool> get shuffleEnabledStream async* {
    yield _settings.shuffle;
    yield* _shuffleController.stream.distinct();
  }

  Stream<LoopMode> get loopModeStream async* {
    yield _settings.repeatMode;
    yield* _loopController.stream.distinct();
  }

  /// Broadcasts the track that [_currentIndex] points at.
  ///
  /// NOTE: this must NOT be derived from `_player.currentIndexStream`. Since
  /// [playAtIndex] loads a single [AudioSource] at a time, the player's own
  /// index is permanently 0, which made this stream always report the first
  /// track in the catalog regardless of what was actually playing.
  final StreamController<Song?> _currentSongController =
      StreamController<Song?>.broadcast();

  /// Replays the current track to every new listener before forwarding
  /// subsequent changes, so `StreamBuilder`s attach with correct data.
  Stream<Song?> get currentSongStream async* {
    yield currentSong;
    yield* _currentSongController.stream;
  }

  void _emitCurrentSong() {
    if (!_currentSongController.isClosed) {
      _currentSongController.add(currentSong);
    }
  }

  Stream<AudioServiceRepeatMode> get repeatModeStream =>
      loopModeStream.map((mode) {
        switch (mode) {
          case LoopMode.off:
            return AudioServiceRepeatMode.none;
          case LoopMode.one:
            return AudioServiceRepeatMode.one;
          case LoopMode.all:
            return AudioServiceRepeatMode.all;
        }
      });

  AudioManager({List<Song>? initialTracks}) {
    if (initialTracks != null) {
      _queue.addAll(initialTracks);
    }
    _applySettingsToPlayer();
    _settings.addListener(_applySettingsToPlayer);

    // Held so it can be cancelled before the player is disposed. Disposing the
    // player would end the stream anyway, but cancelling first makes the
    // teardown order explicit rather than incidental.
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompleted();
      }
    });
    _positionAnalyticsSubscription = _player.positionStream.listen((position) {
      final song = currentSong;
      if (song == null || position < const Duration(seconds: 30)) return;
      if (_thirtySecondTrackIds.add(song.id)) {
        unawaited(AppObservability.instance.playThirtySeconds(song.id));
      }
    });
  }

  Future<void> initializePersistentState() async {
    _prefs = await SharedPreferences.getInstance();
    _favoriteIds
      ..clear()
      ..addAll(_prefs!.getStringList(_favoriteIdsKey) ?? const []);
    _libraryIds
      ..clear()
      ..addAll(_prefs!.getStringList(_libraryIdsKey) ?? const []);
    _downloadedIds
      ..clear()
      ..addAll(_prefs!.getStringList(_downloadedIdsKey) ?? const []);

    final byId = {for (final song in _queue) song.id: song};
    _recent
      ..clear()
      ..addAll(
        (_prefs!.getStringList(_recentIdsKey) ?? const [])
            .map((id) => byId[id])
            .whereType<Song>(),
      );
    notifyListeners();
  }

  void _persistActivity() {
    final prefs = _prefs;
    if (prefs == null) return;
    unawaited(prefs.setStringList(_favoriteIdsKey, _favoriteIds.toList()));
    unawaited(prefs.setStringList(_libraryIdsKey, _libraryIds.toList()));
    unawaited(prefs.setStringList(_downloadedIdsKey, _downloadedIds.toList()));
    unawaited(
      prefs.setStringList(
        _recentIdsKey,
        _recent.map((song) => song.id).toList(),
      ),
    );
  }

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionAnalyticsSubscription;
  final Set<String> _thirtySecondTrackIds = <String>{};

  // ── Play order ───────────────────────────────────────────────────────────
  //
  // `_shuffleOrder` holds queue indices in the order they should play. With
  // shuffle off it is simply 0,1,2… With shuffle on it is a permutation. All
  // next/previous decisions go through it, so shuffle works identically for
  // manual skips and automatic advances.

  final List<int> _shuffleOrder = [];
  final Random _random = Random();

  void _rebuildShuffleOrder() {
    _shuffleOrder
      ..clear()
      ..addAll(List<int>.generate(_queue.length, (i) => i));

    if (!_settings.shuffle || _shuffleOrder.length < 2) return;

    _shuffleOrder.shuffle(_random);

    // Pin the current track to the front so toggling shuffle mid-song doesn't
    // change what is playing right now — only what comes after it.
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      final pos = _shuffleOrder.indexOf(_currentIndex);
      if (pos > 0) {
        _shuffleOrder.removeAt(pos);
        _shuffleOrder.insert(0, _currentIndex);
      }
    }
  }

  /// Queue index [delta] steps from the current one in play order.
  /// Returns null at the boundary when [wrap] is false.
  int? _relativeIndex(int delta, {required bool wrap}) {
    if (_queue.isEmpty) return null;
    if (_shuffleOrder.length != _queue.length) _rebuildShuffleOrder();

    final current = _shuffleOrder.indexOf(_currentIndex);
    final from = current == -1 ? 0 : current;
    var target = from + delta;
    _log(
      '_relativeIndex(delta=$delta wrap=$wrap): '
      'shuffle=${_settings.shuffle} order=$_shuffleOrder '
      'fromPos=$from currentIndex=$_currentIndex',
    );

    if (target < 0 || target >= _shuffleOrder.length) {
      if (!wrap) return null;
      target %= _shuffleOrder.length;
      if (target < 0) target += _shuffleOrder.length;
    }
    return _shuffleOrder[target];
  }

  /// Decides what happens when a track reaches its end.
  ///
  /// Repeat-one never reaches here: the player loops the loaded source itself,
  /// which is gapless and cheaper than reloading the same asset.
  Future<void> _handleTrackCompleted() async {
    final completedSong = currentSong;
    if (completedSong != null) {
      unawaited(AppObservability.instance.playCompleted(completedSong.id));
    }
    _log(
      'completed: repeat=${_settings.repeatMode} '
      'shuffle=${_settings.shuffle} autoplay=${_settings.autoplay}',
    );

    if (!_settings.autoplay) {
      _log('  -> autoplay off, stopping');
      return;
    }

    final next = _relativeIndex(1, wrap: _settings.repeatMode == LoopMode.all);
    if (next == null) {
      _log('  -> end of queue, stopping');
      return;
    }
    await playAtIndex(next);
  }

  // ───────────────────────────────────────────────────────────────────────
  // TEMPORARY DIAGNOSTICS — added 2026-08-10 to verify transport controls on
  // macOS. Debug builds only. Remove this method and its call sites once
  // playback is confirmed. Filter the console with: [VM-AUDIO]
  // ───────────────────────────────────────────────────────────────────────
  void _log(String message) {
    if (kDebugMode) debugPrint('[VM-AUDIO] $message');
  }

  void _applySettingsToPlayer() {
    // Repeat-one is the only mode the player can usefully handle on a single
    // source — it loops that source gaplessly. Every other mode must be off on
    // the player, or repeat-all would loop one song forever instead of moving
    // through the queue. Shuffle is never delegated: a list of one cannot be
    // shuffled.
    _player.setLoopMode(
      _settings.repeatMode == LoopMode.one ? LoopMode.one : LoopMode.off,
    );

    _rebuildShuffleOrder();

    if (!_shuffleController.isClosed) _shuffleController.add(_settings.shuffle);
    if (!_loopController.isClosed) _loopController.add(_settings.repeatMode);
  }

  void _recordRecent(Song? song) {
    if (song == null) return;
    _recent.removeWhere((s) => s.id == song.id);
    _recent.insert(0, song);
    if (_recent.length > _recentLimit) {
      _recent.removeRange(_recentLimit, _recent.length);
    }
    _persistActivity();
  }

  Future<void> setQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue
      ..clear()
      ..addAll(songs);

    if (_queue.isEmpty) {
      _currentIndex = -1;
      _rebuildShuffleOrder();
      await _player.stop();
      _emitCurrentSong();
      notifyListeners();
      return;
    }

    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    _rebuildShuffleOrder();

    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    final index = _queue.indexOf(song);
    if (index != -1) {
      await playAtIndex(index);
    } else {
      await setQueue([song]);
      await playAtIndex(0);
    }
  }

  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    final song = _queue[index];
    _log('playAtIndex($index): ${song.title} — ${song.filePath}');
    try {
      // Load first, so the mini-player never shows a track that has no
      // audio source behind it yet.
      await _player.setAudioSource(
        await MediaSourceResolver.audioSource(song.filePath),
      );
      _log('  -> loaded, reported duration=${_player.duration}');

      _recordRecent(song);
      _emitCurrentSong();
      notifyListeners();

      // IMPORTANT: do not await play(). In just_audio the future returned by
      // play() only completes when playback STOPS or the track ENDS — it is
      // not "playback has started". Awaiting it stalled this method for the
      // whole song, so callers such as _TrendingCard._openNowPlaying never
      // reached their Navigator.push and the player screen never opened.
      unawaited(_player.play());
      unawaited(AppObservability.instance.playStarted(song.id));
      _log('  -> play() requested');
    } catch (e) {
      _log('  !! FAILED to play ${song.filePath}: $e');
      debugPrint('Error playing ${song.filePath}: $e');
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    _log(
      'togglePlayPause: playing=${_player.playing} '
      'state=${_player.processingState} index=$_currentIndex',
    );
    if (_player.playing) {
      await _player.pause();
      _log('  -> paused at ${_player.position}');
    } else if (_player.processingState == ProcessingState.idle &&
        _currentIndex >= 0) {
      _log('  -> idle, reloading track $_currentIndex');
      await playAtIndex(_currentIndex);
    } else {
      // Same rule as playAtIndex: play() must NOT be awaited. Awaiting it here
      // left togglePlayPause pending for the rest of the track, so anything
      // awaiting resume never continued.
      unawaited(_player.play());
      _log('  -> resume requested from ${_player.position}');
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    final song = currentSong;
    if (song != null) {
      unawaited(AppObservability.instance.seek(song.id, position.inSeconds));
    }
  }

  /// Manual skips always wrap, regardless of repeat mode — pressing Next on
  /// the last track goes to the first, which is what every player does.
  Future<void> skipToNext() async {
    _log('skipToNext: from=$_currentIndex queueLength=${_queue.length}');
    if (_queue.isEmpty) {
      _log('  -> ABORTED, queue is empty');
      return;
    }
    final skippedSong = currentSong;
    if (skippedSong != null) {
      unawaited(AppObservability.instance.skip(skippedSong.id, 'next'));
    }
    final next = _relativeIndex(1, wrap: true);
    if (next != null) await playAtIndex(next);
  }

  /// Restarts the current track if more than three seconds have played,
  /// otherwise steps back. Standard behaviour, and it stops an accidental
  /// double-press from skipping two tracks back.
  Future<void> skipToPrevious() async {
    _log('skipToPrevious: from=$_currentIndex pos=${_player.position}');
    if (_queue.isEmpty) {
      _log('  -> ABORTED, queue is empty');
      return;
    }
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    final skippedSong = currentSong;
    if (skippedSong != null) {
      unawaited(AppObservability.instance.skip(skippedSong.id, 'previous'));
    }
    final previous = _relativeIndex(-1, wrap: true);
    if (previous != null) await playAtIndex(previous);
  }

  Future<void> toggleShuffle() async {
    _settings.shuffle = !_settings.shuffle;
    // Logged so a tester can tell a registered tap from a missed one, and can
    // see the resulting play order without reading pixels off the screen.
    _log(
      'toggleShuffle -> ${_settings.shuffle ? "ON" : "OFF"}  '
      'order=$_shuffleOrder  currentIndex=$_currentIndex',
    );
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
    _log('cycleRepeatMode -> $next');
  }

  Future<void> setVolume(double value) async {
    await _player.setVolume(value);
    notifyListeners();
  }

  double get volume => _player.volume;

  bool isDownloaded(Song song) => _downloadedIds.contains(song.id);
  Future<void> download(Song song) async {
    _downloadedIds.add(song.id);
    _persistActivity();
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
    final added = !isFavorite(song);
    if (isFavorite(song)) {
      _favoriteIds.remove(song.id);
    } else {
      _favoriteIds.add(song.id);
    }
    _persistActivity();
    unawaited(AppObservability.instance.favorite(song.id, added: added));
    notifyListeners();
  }

  bool isInLibrary(Song song) => _libraryIds.contains(song.id);
  void addToLibrary(Song song) {
    _libraryIds.add(song.id);
    _persistActivity();
    notifyListeners();
  }

  void removeFromLibrary(Song song) {
    _libraryIds.remove(song.id);
    _persistActivity();
    notifyListeners();
  }

  // ------- Queue management (real implementations) -------

  // The queue is a plain list that this class owns. Mutating it must never
  // touch the player: the loaded AudioSource is the *current track only*, so
  // reordering what comes later has no bearing on what is playing now. These
  // three methods previously rebuilt a ConcatenatingAudioSource of the entire
  // catalog, which reverted the player to the old preload model mid-session
  // and restarted playback.

  /// Append a song to the end of the current queue.
  void addToQueue(Song song) {
    if (_queue.contains(song)) return;
    _queue.add(song);
    _rebuildShuffleOrder();
    notifyListeners();
  }

  /// Insert a song immediately after the currently playing one.
  void playNext(Song song) {
    // Already the current track — nothing meaningful to do.
    if (currentSong == song) return;

    final existing = _queue.indexOf(song);
    if (existing != -1) {
      _queue.removeAt(existing);
      if (existing < _currentIndex) _currentIndex -= 1;
    }

    final insertAt = ((_currentIndex < 0) ? 0 : _currentIndex + 1).clamp(
      0,
      _queue.length,
    );
    _queue.insert(insertAt, song);
    if (insertAt <= _currentIndex) _currentIndex += 1;

    _rebuildShuffleOrder();
    notifyListeners();
  }

  /// Remove a song from the queue. If it was the current track, the song that
  /// takes its slot starts playing; otherwise playback is left undisturbed.
  void removeFromQueue(Song song) {
    final index = _queue.indexOf(song);
    if (index == -1) return;

    final wasCurrent = (index == _currentIndex);
    _queue.removeAt(index);

    if (_queue.isEmpty) {
      _currentIndex = -1;
      _rebuildShuffleOrder();
      _player.stop();
      _emitCurrentSong();
      notifyListeners();
      return;
    }

    if (wasCurrent) {
      _currentIndex = _currentIndex.clamp(0, _queue.length - 1);
      _rebuildShuffleOrder();
      // Load whatever now occupies this slot. Not awaited: callers are UI
      // handlers. playAtIndex rethrows on a failed load, so guard the async
      // tail here to avoid an unhandled exception during a queue edit.
      unawaited(() async {
        try {
          await playAtIndex(_currentIndex);
        } catch (e) {
          _log('removeFromQueue: failed to load replacement track: $e');
          debugPrint('Failed to load replacement track: $e');
        }
      }());
      return;
    }

    // A track elsewhere in the queue went away. Keep the index pointing at the
    // same song and leave the player alone.
    if (index < _currentIndex) _currentIndex -= 1;
    _rebuildShuffleOrder();
    notifyListeners();
  }

  Future<void> playFromQueueSong(Song song) async => playSong(song);

  @override
  void dispose() {
    // Order matters: stop listening, then close controllers, then tear down
    // the player. Reversing it can deliver a final event into a closed sink.
    _playerStateSubscription?.cancel();
    _positionAnalyticsSubscription?.cancel();
    _currentSongController.close();
    _shuffleController.close();
    _loopController.close();
    _settings.removeListener(_applySettingsToPlayer);
    _player.dispose();
    super.dispose();
  }
}
