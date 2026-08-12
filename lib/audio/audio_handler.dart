import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/core/services/media_source_resolver.dart';
import 'package:visionmusicapp/song.dart';

class VisionAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioManager _audioManager;

  /// Every subscription this handler opens, so they can all be cancelled.
  ///
  /// Previously seven `.listen()` calls were made and none were ever held or
  /// cancelled. In practice this handler is created once and lives for the
  /// life of the app, so nothing leaked in normal use — but a second
  /// `AudioService.init` (hot restart, or a future re-init) would have
  /// attached a duplicate set, and every playback event would then be
  /// broadcast twice to the OS media session.
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Throttles position updates. `positionStream` ticks several times a
  /// second; republishing `playbackState` at that rate thrashes the media
  /// notification for no benefit, since the OS only renders whole seconds.
  Duration _lastPublishedPosition = Duration.zero;

  VisionAudioHandler(this._audioManager) {
    // Listen to AudioManager state changes and broadcast to AudioService
    _subscriptions.add(
      _audioManager.currentSongStream.listen((song) {
        if (song != null) {
          _updateMediaItem(song);
        }
      }),
    );

    // Broadcast full player state (processingState + playing + controls).
    // Driven by just_audio's PlayerState so buffering/completed/idle are
    // reported accurately to the OS media notification + lock screen.
    _subscriptions.add(
      _audioManager.playerStateStream.listen((state) {
        final playing = state.playing;
        playbackState.add(
          playbackState.value.copyWith(
            playing: playing,
            controls: [
              MediaControl.skipToPrevious,
              if (playing) MediaControl.pause else MediaControl.play,
              MediaControl.stop,
              MediaControl.skipToNext,
            ],
            systemActions: const {
              MediaAction.seek,
              MediaAction.seekForward,
              MediaAction.seekBackward,
              MediaAction.play,
              MediaAction.pause,
              MediaAction.skipToNext,
              MediaAction.skipToPrevious,
            },
            androidCompactActionIndices: const [0, 1, 3],
            processingState: _mapProcessingState(state.processingState),
          ),
        );
      }),
    );

    _subscriptions.add(
      _audioManager.positionStream.listen((position) {
        // Only republish when the whole-second value actually changes, or when
        // the user has seeked backwards. The OS media session renders seconds,
        // so anything finer is wasted work several times a second.
        final movedForward =
            position.inSeconds != _lastPublishedPosition.inSeconds;
        final seekedBack = position < _lastPublishedPosition;
        if (!movedForward && !seekedBack) return;

        _lastPublishedPosition = position;
        playbackState.add(
          playbackState.value.copyWith(updatePosition: position),
        );
      }),
    );

    _subscriptions.add(
      _audioManager.bufferedPositionStream.listen((buffered) {
        playbackState.add(
          playbackState.value.copyWith(bufferedPosition: buffered),
        );
      }),
    );

    _subscriptions.add(
      _audioManager.speedStream.listen((speed) {
        playbackState.add(playbackState.value.copyWith(speed: speed));
      }),
    );

    _subscriptions.add(
      _audioManager.shuffleEnabledStream.listen((enabled) {
        playbackState.add(
          playbackState.value.copyWith(
            shuffleMode: enabled
                ? AudioServiceShuffleMode.all
                : AudioServiceShuffleMode.none,
          ),
        );
      }),
    );

    _subscriptions.add(
      _audioManager.repeatModeStream.listen((mode) {
        playbackState.add(playbackState.value.copyWith(repeatMode: mode));
      }),
    );
  }

  Future<void> _updateMediaItem(Song song) async {
    Uri? artUri;
    if (song.imagePath != null &&
        MediaSourceResolver.classify(song.imagePath) == MediaLocation.network) {
      // Remote artwork: audio_service fetches http(s) art URIs itself, so
      // copying bytes through rootBundle (which only knows about bundled
      // assets) would fail and leave the lock screen with no artwork.
      artUri = Uri.parse(song.imagePath!.trim());
    } else if (song.imagePath != null) {
      if (kIsWeb) {
        // On web, we can't save to temp directory.
        // We'll try to use the asset path directly if possible, or just skip for now.
        // Most web browsers will handle asset paths or network URIs.
        artUri = Uri.parse(song.imagePath!);
      } else {
        try {
          final byteData = await rootBundle.load(song.imagePath!);
          final bytes = byteData.buffer.asUint8List();
          final tempDir = await getTemporaryDirectory();
          final fileName = song.imagePath!.split('/').last;
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          artUri = file.uri;
        } catch (e) {
          // ignore: avoid_print
          print("Error loading artwork: $e");
        }
      }
    }

    mediaItem.add(
      MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        duration: song.duration,
        artUri: artUri,
      ),
    );
  }

  @override
  Future<void> play() => _audioManager.player.play();

  @override
  Future<void> pause() => _audioManager.player.pause();

  @override
  Future<void> stop() async {
    await _audioManager.player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() => _audioManager.skipToNext();

  @override
  Future<void> skipToPrevious() => _audioManager.skipToPrevious();

  @override
  Future<void> seek(Duration position) => _audioManager.seek(position);

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final shouldEnable = shuffleMode == AudioServiceShuffleMode.all;
    final current =
        playbackState.value.shuffleMode == AudioServiceShuffleMode.all;
    if (current != shouldEnable) {
      await _audioManager.toggleShuffle();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // Cycle repeat mode until it matches what AudioService requested
    for (int i = 0; i < 3; i++) {
      final current = playbackState.value.repeatMode;
      if (current == repeatMode) return;
      await _audioManager.cycleRepeatMode();
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  /// Releases every stream subscription this handler holds.
  ///
  /// Deliberately *not* called from [stop]. In `audio_service`, stop is a
  /// transport command the user can issue and then follow with play — tearing
  /// the subscriptions down there would leave a handler that no longer
  /// reflects playback. This exists for genuine teardown: a re-init, or a test
  /// that builds a handler and needs to dismantle it afterwards.
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
