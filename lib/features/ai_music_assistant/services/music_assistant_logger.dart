import 'dart:developer' as developer;

class MusicAssistantLogger {
  void success({
    required String idea,
    required String responseSummary,
    required bool safeMode,
  }) {
    developer.log(
      'AI Music Assistant success '
      '| ideaLength=${idea.length} '
      '| safeMode=$safeMode '
      '| response=$responseSummary',
      name: 'VisionMusic.AIMusicAssistant',
    );
  }

  void failure({
    required String idea,
    required Object error,
    required bool safeMode,
  }) {
    developer.log(
      'AI Music Assistant failure '
      '| ideaLength=${idea.length} '
      '| safeMode=$safeMode '
      '| error=$error',
      name: 'VisionMusic.AIMusicAssistant',
    );
  }
}
