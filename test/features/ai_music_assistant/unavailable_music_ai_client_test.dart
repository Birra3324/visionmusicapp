import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/music_ai_client.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/music_assistant_service.dart';

void main() {
  test('stub client never hits a network and reports unavailable', () async {
    const client = UnavailableMusicAiClient();
    await expectLater(
      client.generate('any prompt'),
      throwsA(
        isA<MusicAiException>().having(
          (e) => e.message,
          'message',
          UnavailableMusicAiClient.unavailable.message,
        ),
      ),
    );
  });

  test('unavailable factory preserves MusicAiException through the service', () {
    final service = MusicAssistantService.unavailable();
    expect(
      () => service.generate(idea: 'Modern Oromo 6/8 love song', safeMode: true),
      throwsA(isA<MusicAiException>()),
    );
  });
}
