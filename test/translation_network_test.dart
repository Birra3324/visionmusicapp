import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/app/main_shell.dart';
import 'package:visionmusicapp/core/services/video_service.dart';
import 'package:visionmusicapp/features/auth/login_screen.dart';
import 'package:visionmusicapp/features/library/library_hub_screen.dart';
import 'package:visionmusicapp/features/video/video_hub_screen.dart';
import 'package:visionmusicapp/gold_discover_screen.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:visionmusicapp/l10n/localization_delegates.dart';
import 'package:visionmusicapp/mock_videos.dart';
import 'package:visionmusicapp/models/video.dart';
import 'package:visionmusicapp/playlists_screen.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/vision_theme.dart';

class _DelayedCatalog extends VideoService {
  final reads = <Completer<List<Video>>>[];
  @override
  Future<List<VideoCategory>> fetchVideoCategories() async =>
      kDefaultVideoCategories;
  @override
  Future<List<Video>> fetchAllVideos() {
    final read = Completer<List<Video>>();
    reads.add(read);
    return read.future;
  }
}

void main() {
  test(
    'all six catalogs cover every message and preserve interpolation fields',
    () {
      final directory = Directory('lib/l10n');
      final template =
          jsonDecode(File('${directory.path}/app_en.arb').readAsStringSync())
              as Map;
      final keys = template.keys
          .cast<String>()
          .where((key) => !key.startsWith('@'))
          .toSet();
      final placeholder = RegExp(r'\{(\w+)\}');
      for (final locale in AppLocalizations.supportedLocales) {
        final translated =
            jsonDecode(
                  File(
                    '${directory.path}/app_${locale.languageCode}.arb',
                  ).readAsStringSync(),
                )
                as Map;
        expect(
          translated.keys
              .cast<String>()
              .where((key) => !key.startsWith('@'))
              .toSet(),
          keys,
        );
        for (final key in keys) {
          expect(
            (translated[key] as String).trim(),
            isNotEmpty,
            reason: '${locale.languageCode}: $key',
          );
          expect(
            placeholder.allMatches(translated[key]).map((m) => m[1]).toSet(),
            placeholder.allMatches(template[key]).map((m) => m[1]).toSet(),
            reason: '${locale.languageCode}: $key',
          );
        }
      }
    },
  );

  test('web loading and retry copy matches the app locale catalogs', () {
    final script = File('web/loading.js').readAsStringSync();
    final messages =
        jsonDecode(script.split(' = ').skip(1).join(' = ').split(';\n').first)
            as Map;
    for (final locale in AppLocalizations.supportedLocales) {
      final catalog =
          jsonDecode(
                File(
                  'lib/l10n/app_${locale.languageCode}.arb',
                ).readAsStringSync(),
              )
              as Map;
      final loading = messages[locale.languageCode] as Map;
      for (final key in [
        'loadingApp',
        'slowConnection',
        'startupError',
        'retry',
      ]) {
        expect(
          loading[key],
          catalog[key],
          reason: '${locale.languageCode}: $key',
        );
      }
    }
  });

  late AudioManager audio;
  late SettingsManager settings;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsManager();
    await settings.init();
    audio = AudioManager(initialTracks: []);
  });
  tearDown(() => audio.dispose());

  Widget app(
    Widget page, {
    Locale locale = const Locale('en'),
    double scale = 1,
  }) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: audio),
      ChangeNotifierProvider.value(value: settings),
    ],
    child: MaterialApp(
      theme: buildVisionGoldTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: visionLocalizationDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: page,
    ),
  );

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'listener screens fit 320px and 2x text in ${locale.languageCode}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final l10n = lookupAppLocalizations(locale);
        for (final page in <Widget>[
          const LoginScreen(),
          const MainShell(),
          GoldDiscoverScreen(audioManager: audio),
          LibraryHubScreen(audioManager: audio),
          PlaylistsScreen(audioManager: audio),
          VideoHubScreen(service: VideoService(useFirebase: false)),
        ]) {
          await tester.pumpWidget(app(page, locale: locale, scale: 2));
          await tester.pump(const Duration(milliseconds: 200));
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: '${locale.languageCode}: ${page.runtimeType}',
          );
          if (page is MainShell) {
            for (final destination
                in find.byType(NavigationDestination).evaluate().toList()) {
              await tester.tap(find.byWidget(destination.widget));
              await tester.pump(const Duration(milliseconds: 350));
              expect(
                tester.takeException(),
                isNull,
                reason: '${locale.languageCode}: navigation',
              );
            }
          }
          if (page is GoldDiscoverScreen || page is LibraryHubScreen) {
            expect(find.text(l10n.audioCatalogTitle), findsOneWidget);
          }
          if (page is VideoHubScreen) {
            expect(find.text(l10n.openChannel), findsOneWidget);
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        }
      },
    );
  }

  testWidgets(
    'slow video request times out, retry recovers and late responses stay discarded',
    (tester) async {
      final catalog = _DelayedCatalog();
      await tester.pumpWidget(
        app(
          VideoHubScreen(
            service: catalog,
            loadTimeout: const Duration(seconds: 2),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Loading videos…'), findsOneWidget);
      expect(find.text('Open YouTube channel'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('Could not load videos'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(catalog.reads.length, 2);
      catalog.reads.last.complete(mockVideos);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Could not load videos'), findsNothing);
      expect(find.byTooltip('Search videos'), findsOneWidget);
      catalog.reads.first.complete([]);
      await tester.pump();
      expect(find.byTooltip('Search videos'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'delayed video response after leaving the screen causes no disposed-state error',
    (tester) async {
      final catalog = _DelayedCatalog();
      await tester.pumpWidget(app(VideoHubScreen(service: catalog)));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      catalog.reads.single.complete(mockVideos);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
