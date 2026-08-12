enum MusicRecognitionStatus {
  idle,
  requestingPermission,
  listening,
  uploading,
  recognizing,
  matchedInternal,
  matchedExternal,
  noMatch,
  permissionDenied,
  networkError,
  serviceError,
  cancelled,
}

class MusicRecognitionResult {
  final String? title;
  final String? artist;
  final String? album;
  final String? coverUrl;
  final String? isrc;
  final String? songId; // internal track ID if matched
  final Map<String, String>? externalUrls;
  final double? confidence;

  const MusicRecognitionResult({
    this.title,
    this.artist,
    this.album,
    this.coverUrl,
    this.isrc,
    this.songId,
    this.externalUrls,
    this.confidence,
  });

  bool get isInternalMatch => songId != null;
}
