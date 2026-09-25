import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/core/services/app_config.dart';
import 'package:visionmusicapp/features/search/search_hub_screen.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:visionmusicapp/mock_songs.dart';
import 'package:visionmusicapp/settings_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppConfig.enableMusicRecognition = false;
    await SettingsManager.instance.init();
  });

  tearDown(() {
    AppConfig.enableMusicRecognition = false;
  });

  Future<void> pumpSearch(WidgetTester tester) async {
    final audioManager = AudioManager(initialTracks: mockSongs);
    await audioManager.initializePersistentState();
    addTearDown(audioManager.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SearchHubScreen(
          audioManager: audioManager,
          settings: SettingsManager.instance,
        ),
      ),
    );
  }

  testWidgets('search hides the identify mic when recognition is off', (
    tester,
  ) async {
    await pumpSearch(tester);
    expect(find.byIcon(Icons.mic_rounded), findsNothing);
  });

  testWidgets('search shows the identify mic when recognition is on', (
    tester,
  ) async {
    AppConfig.enableMusicRecognition = true;
    await pumpSearch(tester);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
  });
}
