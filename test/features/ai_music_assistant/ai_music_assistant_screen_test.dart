import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/ai_music_assistant/screens/ai_music_assistant_screen.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/http_music_ai_client.dart';
import 'package:visionmusicapp/features/ai_music_assistant/services/music_assistant_service.dart';

void main() {
  testWidgets('AI Music Assistant screen builds with idea/mood/genre fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AiMusicAssistantScreen(
          service: MusicAssistantService(client: HttpMusicAiClient(baseUrl: '')),
        ),
      ),
    );

    expect(find.text('AI Music Assistant'), findsOneWidget);
    expect(find.text('Song idea'), findsOneWidget);
    expect(find.text('Mood'), findsOneWidget);
    expect(find.text('Genre'), findsOneWidget);
    expect(find.text('Generate Production Plan'), findsOneWidget);
  });

  testWidgets('generate without MUSIC_AI_BASE_URL uses the friendly error path', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AiMusicAssistantScreen(
          service: MusicAssistantService(client: HttpMusicAiClient(baseUrl: '')),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Song idea'),
      'Modern Oromo 6/8 love song',
    );
    await tester.tap(find.text('Generate Production Plan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('temporarily unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
