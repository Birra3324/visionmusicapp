import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/recognition_state.dart';
import 'recognition_repository.dart';

class MusicRecognitionService extends ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final MusicRecognitionRepository _repository;

  MusicRecognitionService({required MusicRecognitionRepository repository})
    : _repository = repository;

  MusicRecognitionStatus _status = MusicRecognitionStatus.idle;
  MusicRecognitionStatus get status => _status;

  MusicRecognitionResult? _result;
  MusicRecognitionResult? get result => _result;

  String? _lastRecordedFilePath;
  Timer? _recordingTimer;

  static const Duration _maxRecordingDuration = Duration(seconds: 8);

  void _setStatus(MusicRecognitionStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  Future<void> startRecognition() async {
    if (_status == MusicRecognitionStatus.listening) return;

    _setStatus(MusicRecognitionStatus.requestingPermission);

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _setStatus(MusicRecognitionStatus.permissionDenied);
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/recognition_sample.m4a';
      _lastRecordedFilePath = path;

      final config = const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      _setStatus(MusicRecognitionStatus.listening);
      await _audioRecorder.start(config, path: path);

      _recordingTimer = Timer(_maxRecordingDuration, () {
        stopAndRecognize();
      });
    } catch (e) {
      debugPrint('Error starting recorder: $e');
      _setStatus(MusicRecognitionStatus.serviceError);
    }
  }

  Future<void> stopAndRecognize() async {
    if (_status != MusicRecognitionStatus.listening) return;

    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      final path = await _audioRecorder.stop();
      if (path == null) {
        _setStatus(MusicRecognitionStatus.serviceError);
        return;
      }

      _setStatus(MusicRecognitionStatus.uploading);

      try {
        final recognitionResult = await _repository.recognize(File(path));
        _result = recognitionResult;

        if (recognitionResult == null) {
          _setStatus(MusicRecognitionStatus.noMatch);
        } else if (recognitionResult.isInternalMatch) {
          _setStatus(MusicRecognitionStatus.matchedInternal);
        } else {
          _setStatus(MusicRecognitionStatus.matchedExternal);
        }
      } on HttpException catch (e) {
        debugPrint('Network/Server error: $e');
        _setStatus(MusicRecognitionStatus.serviceError);
      } catch (e) {
        debugPrint('Recognition error: $e');
        _setStatus(MusicRecognitionStatus.networkError);
      } finally {
        // Cleanup temp file
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error stopping recorder: $e');
      _setStatus(MusicRecognitionStatus.serviceError);
    }
  }

  Future<void> cancel() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }

    if (_lastRecordedFilePath != null) {
      final file = File(_lastRecordedFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _setStatus(MusicRecognitionStatus.idle);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
}
