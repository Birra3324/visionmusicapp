abstract class MusicAiClient {
  Future<String> generate(String prompt);
}

class MusicAiException implements Exception {
  final String message;

  const MusicAiException(this.message);

  @override
  String toString() => message;
}
