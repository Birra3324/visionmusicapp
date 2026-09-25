import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/core/services/app_config.dart';

void main() {
  test('store defaults keep catalog local and optional features off', () {
    expect(AppConfig.useFirebaseCatalog, isFalse);
    expect(AppConfig.fallbackToLocalOnEmpty, isTrue);
    expect(AppConfig.enableAiMusicAssistant, isFalse);
    expect(AppConfig.enableMusicRecognition, isFalse);
    expect(AppConfig.privacyPolicyUrl, startsWith('https://'));
    expect(AppConfig.privacyPolicyUrl, contains('visionmusic.et'));
  });
}
