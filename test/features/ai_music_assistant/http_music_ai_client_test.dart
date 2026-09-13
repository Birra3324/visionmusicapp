import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/http_music_ai_client.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/music_ai_client.dart';

void main() {
  group('HttpMusicAiClient', () {
    test('throws a clear error when MUSIC_AI_BASE_URL is empty', () async {
      final client = HttpMusicAiClient(baseUrl: '');

      expect(
        () => client.generate('a prompt'),
        throwsA(
          isA<MusicAiException>().having(
            (e) => e.message,
            'message',
            contains('AI backend not configured'),
          ),
        ),
      );
    });

    test('throws a clear error when the base URL is only whitespace', () {
      final client = HttpMusicAiClient(baseUrl: '   ');

      expect(
        client.resolveEndpoint,
        throwsA(
          isA<MusicAiException>().having(
            (e) => e.message,
            'message',
            contains('AI backend not configured'),
          ),
        ),
      );
    });

    test('POSTs the prompt and returns the response body', () async {
      http.Request? captured;
      final httpClient = MockClient((request) async {
        captured = request;
        return http.Response('{"productionPrompt":"ok"}', 200);
      });

      final client = HttpMusicAiClient(
        httpClient: httpClient,
        baseUrl: 'https://ai.example.com/v1/generate',
      );

      final body = await client.generate('Modern Oromo 6/8 love song');

      expect(body, '{"productionPrompt":"ok"}');
      expect(captured, isNotNull);
      expect(captured!.method, 'POST');
      expect(
        captured!.url,
        Uri.parse('https://ai.example.com/v1/generate'),
      );
      expect(jsonDecode(captured!.body), {'prompt': 'Modern Oromo 6/8 love song'});
    });

    test('joins an optional path onto the base URL', () async {
      http.Request? captured;
      final httpClient = MockClient((request) async {
        captured = request;
        return http.Response('ok', 200);
      });

      final client = HttpMusicAiClient(
        httpClient: httpClient,
        baseUrl: 'https://ai.example.com',
        path: '/v1/generate',
      );

      await client.generate('idea');

      expect(
        captured!.url,
        Uri.parse('https://ai.example.com/v1/generate'),
      );
    });

    test('maps a non-2xx status to MusicAiException', () async {
      final httpClient = MockClient((_) async {
        return http.Response('nope', 503);
      });

      final client = HttpMusicAiClient(
        httpClient: httpClient,
        baseUrl: 'https://ai.example.com/generate',
      );

      expect(
        () => client.generate('idea'),
        throwsA(
          isA<MusicAiException>().having(
            (e) => e.message,
            'message',
            contains('HTTP 503'),
          ),
        ),
      );
    });
  });
}
