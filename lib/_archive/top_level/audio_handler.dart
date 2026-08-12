import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'audio_manager.dart';
import 'song.dart';

class VisionAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioManager _audioManager;
  bool _isPlaying = false;

  VisionAudioHandler(this._audioManager) {
    _audioManager.currentSongStream.listen((song) {
      if (song != null) {
        _updateMediaItem(song);
      }
    });

    _audioManager.isPlayingStream.listen((isPlaying) {
      _isPlaying = isPlaying;
      playbackState.add(
        playbackState.value.copyWith(
          playing: isPlaying,
          controls: [
            MediaControl.skipToPrevious,
            if (isPlaying) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: AudioProcessingState.ready,
        ),
      );
    });

    _audioManager.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    _audioManager.shuffleEnabledStream.listen((enabled) {
      playbackState.add(
        playbackState.value.copyWith(
          shuffleMode: enabled
              ? AudioServiceShuffleMode.all
              : AudioServiceShuffleMode.none,
        ),
      );
    });

    _audioManager.repeatModeStream?.listen((mode) {
      playbackState.add(playbackState.value.copyWith(repeatMode: mode));
    });
  }

  Future<void> _updateMediaItem(Song song) async {
    Uri? artUri;

    final artPath = song.imagePath;
    if (artPath != null) {
      try {
        final byteData = await rootBundle.load(artPath);
        final bytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final fileName = artPath.split('/').last;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        artUri = file.uri;
      } catch (e) {
        // ignore: avoid_print
        print('Error loading artwork for lock screen: $e');
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
  Future<void> play() async {
    if (!_isPlaying) {
      _audioManager.togglePlayPause();
    }
  }

  @override
  Future<void> pause() async {
    if (_isPlaying) {
      _audioManager.togglePlayPause();
    }
  }

  @override
  Future<void> skipToNext() async => _audioManager.skipToNext();

  @override
  Future<void> skipToPrevious() async => _audioManager.skipToPrevious();

  @override
  Future<void> seek(Duration position) async => _audioManager.seek(position);

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
    for (int i = 0; i < 3; i++) {
      final current = playbackState.value.repeatMode;
      if (current == repeatMode) return;
      await _audioManager.cycleRepeatMode();
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }
}
