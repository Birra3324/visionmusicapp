class MusicAssistantValidator {
  static const int maxIdeaLength = 1000;

  static String? validate({
    required String idea,
    String? mood,
    String? genre,
  }) {
    final cleanedIdea = idea.trim();

    if (cleanedIdea.isEmpty) {
      return 'Enter a song idea before generating.';
    }

    if (cleanedIdea.length < 3) {
      return 'Please describe your song idea in a little more detail.';
    }

    if (cleanedIdea.length > maxIdeaLength) {
      return 'Song idea must be under $maxIdeaLength characters.';
    }

    return null;
  }
}
