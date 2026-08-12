// Subtitle Service
// Generates SRT (SubRip) and VTT (WebVTT) subtitle files from lyrics
// TODO: Connect to Whisper for time-aligned transcription

class SubtitleService {
  static final SubtitleService _instance = SubtitleService._internal();

  factory SubtitleService() => _instance;
  SubtitleService._internal();

  /// Generate SRT subtitle file from lyrics
  /// SRT format: index, time range, text, blank line
  String generateSRT(String lyrics, {Duration startTime = Duration.zero}) {
    final lines = lyrics
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    final srtLines = <String>[];

    int index = 1;
    Duration currentTime = startTime;
    const lineDuration = Duration(
      seconds: 3,
    ); // Each line displays for 3 seconds

    for (final line in lines) {
      final endTime = currentTime + lineDuration;

      srtLines.add(index.toString());
      srtLines.add(
        '${_formatSRTTime(currentTime)} --> ${_formatSRTTime(endTime)}',
      );
      srtLines.add(line);
      srtLines.add(''); // Blank line between entries

      index++;
      currentTime = endTime;
    }

    return srtLines.join('\n');
  }

  /// Generate VTT (WebVTT) subtitle file from lyrics
  /// VTT format: Header, cue block (time --> time, text), blank line
  String generateVTT(String lyrics, {Duration startTime = Duration.zero}) {
    final lines = lyrics
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    final vttLines = <String>['WEBVTT', ''];

    Duration currentTime = startTime;
    const lineDuration = Duration(seconds: 3);

    for (final line in lines) {
      final endTime = currentTime + lineDuration;

      vttLines.add(
        '${_formatVTTTime(currentTime)} --> ${_formatVTTTime(endTime)}',
      );
      vttLines.add(line);
      vttLines.add('');

      currentTime = endTime;
    }

    return vttLines.join('\n');
  }

  /// Time-aligned subtitles (requires Whisper transcription data)
  /// Takes lyrics and alignment data from audio analysis
  String generateAlignedSRT(
    String lyrics, {
    required List<Map<String, dynamic>> timeAlignments,
  }) {
    // TODO: Implement time-aligned subtitle generation
    // timeAlignments format: [{'text': 'Line 1', 'startTime': 0, 'endTime': 3}, ...]
    return generateSRT(lyrics);
  }

  /// Format duration for SRT (HH:MM:SS,mmm)
  String _formatSRTTime(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final millis = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$millis';
  }

  /// Format duration for VTT (HH:MM:SS.mmm)
  String _formatVTTTime(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final millis = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds.$millis';
  }

  /// Export subtitle file (returns file content as string)
  /// User can save to device storage
  String exportSubtitles(String lyrics, {required String format}) {
    switch (format.toLowerCase()) {
      case 'srt':
        return generateSRT(lyrics);
      case 'vtt':
        return generateVTT(lyrics);
      default:
        return generateSRT(lyrics);
    }
  }
}
