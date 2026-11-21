import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';
import 'package:visionmusicapp/features/recognition/domain/recognition_state.dart';
import 'package:visionmusicapp/features/recognition/services/recognition_repository.dart';
import 'package:visionmusicapp/features/recognition/services/recognition_service.dart';

class _Recorder implements AudioRecorder {
  _Recorder(this.allowed, {this.permissionError});
  final bool allowed;
  final Object? permissionError;
  final requests = <bool>[];
  int starts = 0;
  bool recording = false;
  @override
  Future<bool> hasPermission({bool request = true}) async {
    requests.add(request);
    if (permissionError != null) throw permissionError!;
    return allowed;
  }

  @override
  Future<void> start(RecordConfig config, {required String path}) async {
    starts++;
    recording = true;
  }

  @override
  Future<bool> isRecording() async => recording;
  @override
  Future<String?> stop() async {
    recording = false;
    return null;
  }

  @override
  Future<void> dispose() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporary;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('vision-mic-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => temporary.path,
        );
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    await temporary.delete(recursive: true);
  });

  for (final allowed in [true, false]) {
    test(
      'recorder microphone permission ${allowed ? "allow" : "deny"} controls capture',
      () async {
        final recorder = _Recorder(allowed);
        final service = MusicRecognitionService(
          repository: MusicRecognitionRepository(
            baseUrl: 'https://example.invalid',
          ),
          recorder: recorder,
        );
        await service.startRecognition();
        expect(recorder.requests, [true]);
        expect(recorder.starts, allowed ? 1 : 0);
        expect(
          service.status,
          allowed
              ? MusicRecognitionStatus.listening
              : MusicRecognitionStatus.permissionDenied,
        );
        await service.cancel();
        expect(recorder.recording, isFalse);
        expect(service.status, MusicRecognitionStatus.idle);
        service.dispose();
      },
    );
  }

  test('microphone permission API error never starts capture', () async {
    final recorder = _Recorder(
      false,
      permissionError: PlatformException(code: 'unavailable'),
    );
    final service = MusicRecognitionService(
      repository: MusicRecognitionRepository(
        baseUrl: 'https://example.invalid',
      ),
      recorder: recorder,
    );
    await service.startRecognition();
    expect(service.status, MusicRecognitionStatus.serviceError);
    expect(recorder.starts, 0);
    service.dispose();
  });
}
