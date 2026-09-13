import 'dart:convert';

import 'package:http/http.dart' as http;

import 'music_ai_client.dart';

/// Production [MusicAiClient] that POSTs the prompt to a configured backend.
///
/// Configure at build time — never put API keys in the Flutter client:
/// `flutter run --dart-define=MUSIC_AI_BASE_URL=https://example.com`
/// `flutter run --dart-define=MUSIC_AI_PATH=/v1/generate`
class HttpMusicAiClient implements MusicAiClient {
  HttpMusicAiClient({
    http.Client? httpClient,
    this.baseUrl = const String.fromEnvironment('MUSIC_AI_BASE_URL'),
    this.path = const String.fromEnvironment('MUSIC_AI_PATH'),
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String baseUrl;
  final String path;

  static const _notConfiguredMessage =
      'AI backend not configured. Set MUSIC_AI_BASE_URL.';

  @override
  Future<String> generate(String prompt) async {
    final endpoint = resolveEndpoint();

    final response = await _httpClient.post(
      endpoint,
      headers: const {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json, text/plain, */*',
      },
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MusicAiException(
        'AI backend returned HTTP ${response.statusCode}.',
      );
    }

    return response.body;
  }

  /// Visible for tests. Joins [baseUrl] with the optional [path].
  Uri resolveEndpoint() {
    final trimmedBase = baseUrl.trim();
    if (trimmedBase.isEmpty) {
      throw const MusicAiException(_notConfiguredMessage);
    }

    final extra = path.trim();
    final combined = extra.isEmpty
        ? trimmedBase
        : _joinBaseAndPath(trimmedBase, extra);

    final uri = Uri.tryParse(combined);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const MusicAiException(_notConfiguredMessage);
    }

    return uri;
  }

  static String _joinBaseAndPath(String base, String extra) {
    final normalizedBase =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final normalizedPath = extra.startsWith('/') ? extra : '/$extra';
    return '$normalizedBase$normalizedPath';
  }
}
