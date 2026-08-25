import 'dart:convert';

import '../models/music_assistant_result.dart';
import 'music_ai_client.dart';
import 'music_prompt_builder.dart';

class MusicAssistantService {
  final MusicAiClient client;

  MusicAssistantService({
    required this.client,
  });

  Future<MusicAssistantResult> generate({
    required String idea,
    String? mood,
    String? genre,
    required bool safeMode,
  }) async {
    final prompt = MusicPromptBuilder.build(
      idea: idea,
      mood: mood,
      genre: genre,
      safeMode: safeMode,
    );

    try {
      final response = await client.generate(prompt);

      final json = _decodeResponse(response);

      final result = MusicAssistantResult.fromJson(json);

      if (!result.isValid) {
        throw const MusicAiException(
          'The AI returned an incomplete production plan.',
        );
      }

      return result;
    } on MusicAiException {
      rethrow;
    } catch (_) {
      throw const MusicAiException(
        'AI generation is temporarily unavailable.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(String response) {
    var cleaned = response.trim();

    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    final decoded = jsonDecode(cleaned.trim());

    if (decoded is! Map<String, dynamic>) {
      throw const MusicAiException(
        'The AI returned an invalid response.',
      );
    }

    return decoded;
  }
}
