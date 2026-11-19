import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:visionmusicapp/main.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/widgets/playlist_name_dialog.dart';

/// Same real app, Search TextField and playlist dialog on the host and Android.
/// The Dart Firebase bootstrap is not run; expected legacy errors are captured.
void registerTextFieldLocaleRegressions() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'saved ${locale.languageCode} locale and focused Search/dialog language changes',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'localeCode': locale.languageCode,
        });
        final settings = SettingsManager();
        await settings.init();
        final audio = AudioManager(
          initialTracks: const [
            Song(
              id: 'locale-regression-fixture',
              title: 'Fixture',
              artist: 'QA',
              filePath: 'https://example.invalid/never-played.mp3',
            ),
          ],
        );
        try {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: settings),
                ChangeNotifierProvider.value(value: audio),
              ],
              child: const VisionMusicApp(firebaseBootstrapResult: null),
            ),
          );
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 10),
          );
          var strings = lookupAppLocalizations(locale);
          await tester.tap(find.text(strings.continueAsGuest));
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 10),
          );
          await tester.tap(
            find.byWidgetPredicate(
              (w) => w is NavigationDestination && w.label == strings.search,
            ),
          );
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 10),
          );
          final search = find.byType(TextField);
          await tester.enterText(search, 'Fixture');
          await tester.pump();
          expect(tester.widget<TextField>(search).controller!.text, 'Fixture');
          expect(
            MaterialLocalizations.of(tester.element(search)).searchFieldLabel,
            isNotEmpty,
          );

          // Rebuild the focused EditableText/ListenableBuilder in another locale.
          settings.localeCode = locale.languageCode == 'om' ? 'en' : 'om';
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump();
          expect(tester.widget<TextField>(search).controller!.text, 'Fixture');
          expect(
            MaterialLocalizations.of(tester.element(search)).searchFieldLabel,
            isNotEmpty,
          );
          expect(tester.takeException(), isNull);

          final result = showPlaylistNameDialog(tester.element(search));
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump();
          final dialogField = find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextField),
          );
          await tester.enterText(dialogField, 'Locale regression');
          settings.localeCode = locale.languageCode;
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump();
          strings = lookupAppLocalizations(locale);
          expect(
            MaterialLocalizations.of(
              tester.element(dialogField),
            ).cancelButtonLabel,
            isNotEmpty,
          );
          expect(
            tester.widget<TextField>(dialogField).controller!.text,
            'Locale regression',
          );
          final editable = find.descendant(
            of: dialogField,
            matching: find.byType(EditableText),
          );
          expect(
            tester.widget<EditableText>(editable).focusNode.hasFocus,
            isTrue,
          );
          // Finish focused-field assertions before dismissing the test input
          // and submitting the visible localized action.
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 10),
          );
          final create = find.widgetWithText(TextButton, strings.create);
          expect(tester.widget<TextButton>(create).onPressed, isNotNull);
          await tester.ensureVisible(create);
          await tester.tap(create);
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump();
          expect(
            await result.timeout(const Duration(seconds: 10)),
            'Locale regression',
          );
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          audio.dispose();
        }
      },
    );
  }
}

void registerLegacyLocaleControl() {
  testWidgets(
    'legacy delegates reproduce missing MaterialLocalizations for Oromo TextField',
    (tester) async {
      final unsupported = AppLocalizations.supportedLocales.where(
        (locale) => !GlobalMaterialLocalizations.delegate.isSupported(locale),
      );
      expect(unsupported.map((l) => l.languageCode), ['om']);
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('om'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: Material(child: Center(child: TextField())),
          ),
        );
        await tester.pump();
        expect(
          errors.any(
            (error) =>
                error.exceptionAsString().contains('MaterialLocalizations') ||
                error.exceptionAsString().contains('Null check operator'),
          ),
          isTrue,
        );
        if (kProfileMode || kReleaseMode) {
          final textFieldErrors = errors.where(
            (error) =>
                error.exceptionAsString().contains('Null check operator') &&
                (error.stack?.toString().contains(
                      '_TextFieldState._getEffectiveDecoration',
                    ) ??
                    false),
          );
          expect(
            textFieldErrors,
            isNotEmpty,
            reason:
                'Match the beta MaterialLocalizations.of / TextField decoration stack.',
          );
          debugPrint(
            'Legacy Oromo control: Null check operator; MaterialLocalizations.of -> _TextFieldState._getEffectiveDecoration',
          );
        }
      } finally {
        FlutterError.onError = previous;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    },
  );
}
