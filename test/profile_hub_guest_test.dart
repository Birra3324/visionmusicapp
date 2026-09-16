import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/core/services/app_config.dart';
import 'package:visionmusicapp/features/profile/profile_hub_screen.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:visionmusicapp/mock_songs.dart';
import 'package:visionmusicapp/settings_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppConfig.enableAiMusicAssistant = false;
    await SettingsManager.instance.init();
  });

  tearDown(() {
    AppConfig.enableAiMusicAssistant = false;
  });

  testWidgets('guest profile keeps sign-out and AI entry hidden by default', (
    tester,
  ) async {
    final audioManager = AudioManager(initialTracks: mockSongs);
    await audioManager.initializePersistentState();
    addTearDown(audioManager.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AudioManager>.value(value: audioManager),
          ChangeNotifierProvider<SettingsManager>.value(
            value: SettingsManager.instance,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileHubScreen(),
        ),
      ),
    );

    expect(find.text('Guest listener'), findsOneWidget);
    expect(find.byKey(const Key('profile_privacy_policy')), findsOneWidget);
    expect(find.byKey(const Key('profile_sign_out')), findsNothing);
    expect(find.byKey(const Key('profile_ai_music_assistant')), findsNothing);
  });

  testWidgets('AI Music Assistant tile appears only when the flag is on', (
    tester,
  ) async {
    AppConfig.enableAiMusicAssistant = true;
    final audioManager = AudioManager(initialTracks: mockSongs);
    await audioManager.initializePersistentState();
    addTearDown(audioManager.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AudioManager>.value(value: audioManager),
          ChangeNotifierProvider<SettingsManager>.value(
            value: SettingsManager.instance,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileHubScreen(),
        ),
      ),
    );

    expect(find.byKey(const Key('profile_ai_music_assistant')), findsOneWidget);
  });
}
