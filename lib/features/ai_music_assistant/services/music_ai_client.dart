abstract class MusicAiClient {
  Future<String> generate(String prompt);
}

class MusicAiException implements Exception {
  final String message;

  const MusicAiException(this.message);

  @override
  String toString() => message;
}

/// Safe production stub. This client repo has no generate endpoint, Cloud
/// Function URL, or env var for Music Assistant. The stub never performs
/// I/O and never invents a backend host.
class UnavailableMusicAiClient implements MusicAiClient {
  const UnavailableMusicAiClient();

  static const MusicAiException unavailable = MusicAiException(
    'AI Music Assistant is not connected to a backend in this build.',
  );

  @override
  Future<String> generate(String prompt) async {
    throw unavailable;
  }
}
