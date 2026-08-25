import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/music_assistant_validator.dart';

void main() {
  group('MusicAssistantValidator', () {
    test('rejects empty song idea', () {
      final result = MusicAssistantValidator.validate(
        idea: '',
      );

      expect(result, isNotNull);
    });

    test('accepts normal song idea', () {
      final result = MusicAssistantValidator.validate(
        idea: 'Modern Oromo 6/8 love song',
        mood: 'Emotional',
        genre: 'Oromo pop',
      );

      expect(result, isNull);
    });

    test('rejects oversized input', () {
      final result = MusicAssistantValidator.validate(
        idea: 'a' * 1001,
      );

      expect(result, isNotNull);
    });
  });
}
