class MusicPromptBuilder {
  static String build({
    required String idea,
    String? mood,
    String? genre,
    required bool safeMode,
  }) {
    final cleanedMood = mood?.trim();
    final cleanedGenre = genre?.trim();

    return '''
You are a professional music production assistant.

Create a useful production plan from the user's song concept.

SONG IDEA:
${idea.trim()}

MOOD:
${cleanedMood?.isNotEmpty == true ? cleanedMood : 'Not specified'}

GENRE:
${cleanedGenre?.isNotEmpty == true ? cleanedGenre : 'Not specified'}

SAFE MODE:
${safeMode ? 'Enabled' : 'Standard'}

${safeMode ? '''
Keep all recommendations suitable for a general audience.
Do not produce explicit sexual, hateful, violent, dangerous, or abusive content.
''' : ''}

Return ONLY valid JSON using exactly this structure:

{
  "productionPrompt": "Detailed production prompt",
  "arrangement": [
    "Intro — description",
    "Verse — description",
    "Chorus — description"
  ],
  "instrumentation": [
    "Instrument and its role"
  ],
  "productionDirection": "Mixing, energy, sonic identity, vocal and production direction"
}

Requirements:
- Respect the user's musical identity and genre.
- Do not invent factual claims about specific artists.
- Make the arrangement musically practical.
- Give instruments a clear purpose.
- Avoid vague recommendations.
- Keep the production prompt concise enough to use with a music-production AI.
''';
  }
}
