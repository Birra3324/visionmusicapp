import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import '../domain/recognition_state.dart';

class MusicRecognitionRepository {
  final String baseUrl;
  final http.Client _client;

  MusicRecognitionRepository({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<MusicRecognitionResult?> recognize(File audioFile) async {
    final url = Uri.parse('$baseUrl/recognize');

    final request = http.MultipartRequest('POST', url);

    // 1. Inject Auth Token
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to recognize music.');
    }
    final token = await user.getIdToken();
    request.headers['Authorization'] = 'Bearer $token';

    // 2. Inject App Check Token (Optional based on environment)
    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken();
      if (appCheckToken != null) {
        request.headers['X-Firebase-AppCheck'] = appCheckToken;
      }
    } catch (e) {
      // Log but don't block; backend may be in dev mode
    }

    // 3. Attach Sample
    request.files.add(
      await http.MultipartFile.fromPath('sample', audioFile.path),
    );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final status = data['status'];

      if (status == 'no_match') {
        return null; // Explicitly no match
      }

      if (status == 'matched') {
        final match = data['match'];
        return MusicRecognitionResult(
          title: match['title'],
          artist: match['artist'],
          album: match['album'],
          coverUrl: match['coverUrl'],
          isrc: match['isrc'],
          songId: match['songId'],
          externalUrls: match['externalUrls'] != null
              ? Map<String, String>.from(match['externalUrls'])
              : null,
          confidence: (data['debug']?['confidence'] as num?)?.toDouble(),
        );
      }
    }

    // Handle errors (4xx, 500)
    throw HttpException(
      'Recognition failed with status: ${response.statusCode}',
      uri: url,
    );
  }
}
