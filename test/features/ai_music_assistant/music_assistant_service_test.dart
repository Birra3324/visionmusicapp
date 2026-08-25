import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/ai_music_assistant/models/music_assistant_result.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/music_ai_client.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/music_assistant_service.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/music_prompt_builder.dart';

class FakeMusicAiClient implements MusicAiClient {
  final String response;

  FakeMusicAiClient(this.response);

  @override
  Future<String> generate(String prompt) async {
    return response;
  }
}

class ThrowingMusicAiClient implements MusicAiClient {
  final Object error;

  ThrowingMusicAiClient(this.error);

  @override
  Future<String> generate(String prompt) async {
    throw error;
  }
}

const _validJson = '''
{
  "productionPrompt": "A cinematic Oromo pop production with warm vocals.",
  "arrangement": [
    "Intro — soft keyboards",
    "Verse — sparse percussion",
    "Chorus — full band"
  ],
  "instrumentation": [
    "Krar — melodic lead",
    "Synth pads — atmosphere"
  ],
  "productionDirection": "Warm, emotional mix with present vocals."
}
''';

void main() {
  group('MusicAssistantService', () {
    test('parses valid AI JSON into a result', () async {
      final service = MusicAssistantService(
        client: FakeMusicAiClient(_validJson),
      );

      final result = await service.generate(
        idea: 'Modern Oromo 6/8 love song',
        safeMode: true,
      );

      expect(result, isA<MusicAssistantResult>());
      expect(result.arrangement.length, 3);
      expect(result.instrumentation.length, 2);
      expect(result.productionPrompt, isNotEmpty);
    });

    test('strips markdown code-fence from AI response', () async {
      final fenced = '```json\n$_validJson\n```';
      final service = MusicAssistantService(
        client: FakeMusicAiClient(fenced),
      );

      final result = await service.generate(
        idea: 'Modern Oromo 6/8 love song',
        safeMode: true,
      );

      expect(result.isValid, isTrue);
    });

    test('throws controlled error on malformed JSON', () async {
      final service = MusicAssistantService(
        client: FakeMusicAiClient('this is not json'),
      );

      expect(
        () => service.generate(
          idea: 'Modern Oromo 6/8 love song',
          safeMode: true,
        ),
        throwsA(
          isA<MusicAiException>().having(
            (e) => e.message,
            'message',
            'AI generation is temporarily unavailable.',
          ),
        ),
      );
    });

    test('throws controlled error on incomplete AI response', () async {
      final incomplete = '''
{
  "productionPrompt": "Only a prompt, no arrangement."
}
''';
      final service = MusicAssistantService(
        client: FakeMusicAiClient(incomplete),
      );

      expect(
        () => service.generate(
          idea: 'Modern Oromo 6/8 love song',
          safeMode: true,
        ),
        throwsA(
          isA<MusicAiException>().having(
            (e) => e.message,
            'message',
            'The AI returned an incomplete production plan.',
          ),
        ),
      );
    });

    test('maps a network/API failure to a fallback error', () async {
      final service = MusicAssistantService(
        client: ThrowingMusicAiClient(Exception('network down')),
      );

      expect(
        () => service.generate(
          idea: 'Modern Oromo 6/8 love song',
          safeMode: true,
        ),
        throwsA(
          isA<MusicAiException>().having(
            (e) => e.message,
            'message',
            'AI generation is temporarily unavailable.',
          ),
        ),
      );
    });

    test('preserves a MusicAiException thrown by the client', () async {
      final service = MusicAssistantService(
        client: ThrowingMusicAiClient(
          const MusicAiException('backend rejected request'),
        ),
      );

      expect(
        () => service.generate(
          idea: 'Modern Oromo 6/8 love song',
          safeMode: true,
        ),
        throwsA(
          isA<MusicAiException>().having(
            (e) => e.message,
            'message',
            'backend rejected request',
          ),
        ),
      );
    });
  });

  group('MusicPromptBuilder', () {
    test('includes safety instruction when safe mode is ON', () {
      final prompt = MusicPromptBuilder.build(
        idea: 'Modern Oromo 6/8 love song',
        safeMode: true,
      );

      expect(prompt, contains('SAFE MODE:\nEnabled'));
      expect(prompt, contains('general audience'));
      expect(prompt, contains('Return ONLY valid JSON'));
    });

    test('omits safety instruction when safe mode is OFF', () {
      final prompt = MusicPromptBuilder.build(
        idea: 'Modern Oromo 6/8 love song',
        safeMode: false,
      );

      expect(prompt, contains('SAFE MODE:\nStandard'));
      expect(prompt, isNot(contains('general audience')));
    });

    test('uses "Not specified" for missing mood and genre', () {
      final prompt = MusicPromptBuilder.build(
        idea: 'Modern Oromo 6/8 love song',
        safeMode: true,
      );

      expect(prompt, contains('MOOD:\nNot specified'));
      expect(prompt, contains('GENRE:\nNot specified'));
    });
  });
}
