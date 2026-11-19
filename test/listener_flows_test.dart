import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/audio_manager.dart';
import 'package:visionmusicapp/gold_discover_screen.dart';
import 'package:visionmusicapp/playlists_screen.dart';
import 'package:visionmusicapp/features/profile/profile_hub_screen.dart';
import 'package:visionmusicapp/features/search/search_hub_screen.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:visionmusicapp/l10n/localization_delegates.dart';
import 'package:visionmusicapp/settings_manager.dart';
import 'package:visionmusicapp/song.dart';
import 'package:visionmusicapp/vision_theme.dart';
import 'package:visionmusicapp/widgets/song_more_options_button.dart';

void main() {
  const song = Song(
    id: 'qa-real-track',
    title: 'Test release',
    artist: 'Catalog artist',
    filePath: 'https://example.test/master.mp3',
  );
  late SettingsManager settings;
  late AudioManager manager;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsManager();
    await settings.init();
    manager = AudioManager(initialTracks: []);
  });
  tearDown(() => manager.dispose());

  Widget app(
    Widget child, {
    Locale locale = const Locale('en'),
    double scale = 1,
    double keyboardHeight = 0,
  }) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: manager),
    ],
    child: MaterialApp(
      theme: buildVisionGoldTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: visionLocalizationDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboardHeight),
        ),
        child: child!,
      ),
      home: child,
    ),
  );

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'profile and framework controls render at large text in ${locale.languageCode}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        settings.localeCode = locale.languageCode;
        await tester.pumpWidget(
          app(const ProfileHubScreen(), locale: locale, scale: 2),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(ProfileHubScreen));
        expect(MaterialLocalizations.of(context).backButtonTooltip, isNotEmpty);
        expect(CupertinoLocalizations.of(context).copyButtonLabel, isNotEmpty);
        expect(AppLocalizations.of(context)!.localeName, locale.languageCode);
        expect(
          Directionality.of(context),
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
      },
    );
  }

  testWidgets(
    'empty search offers real Watch navigation without sample suggestions or keyboard overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          SearchHubScreen(audioManager: manager, settings: settings),
          scale: 2,
          keyboardHeight: 200,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ali Birra'), findsNothing);
      expect(find.text('Shukri Jamal'), findsNothing);
      expect(find.text('Watch music videos'), findsOneWidget);
    },
  );

  testWidgets(
    'new playlist from a song survives dialog handoff and persists its stable ID',
    (tester) async {
      manager.dispose();
      manager = AudioManager(initialTracks: [song]);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: SongMoreOptionsButton(song: song, audioManager: manager),
          ),
        ),
      );
      await tester.tap(find.byTooltip('More options for Test release'));
      await tester.pumpAndSettle();
      expect(find.text('Download'), findsNothing);
      await tester.tap(find.text('Add to Playlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New Playlist'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  First releases  ');
      await tester.pump();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Added to playlist.'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('vision_playlists_v1'), contains('qa-real-track'));
      expect(
        prefs.getString('vision_playlists_v1'),
        contains('First releases'),
      );
    },
  );
  testWidgets('guest Home works when Firebase is unavailable', (tester) async {
    await tester.pumpWidget(app(GoldDiscoverScreen(audioManager: manager)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Welcome to Vision Music'), findsOneWidget);
    expect(find.text('Watch music videos'), findsOneWidget);
  });

  testWidgets('search suggestions come only from the current catalog', (
    tester,
  ) async {
    manager.dispose();
    manager = AudioManager(initialTracks: [song]);
    await tester.pumpWidget(
      app(SearchHubScreen(audioManager: manager, settings: settings)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Catalog artist'), findsOneWidget);
    expect(find.text('Ali Birra'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Test release');
    await tester.pumpAndSettle();
    expect(find.text('Test release'), findsWidgets);
    final semantics = tester.ensureSemantics();
    try {
      await tester.pump();
      expect(
        find.bySemanticsLabel(
          RegExp(r'^Play Test release by Catalog artist(?:\n|$)'),
        ),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'playlist create rename and delete work without touching the catalog',
    (tester) async {
      await tester.pumpWidget(app(PlaylistsScreen(audioManager: manager)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Playlist'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'QA playlist');
      await tester.pump();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('QA playlist'), findsOneWidget);
      await tester.tap(find.byTooltip('Manage QA playlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Renamed playlist');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Renamed playlist'), findsOneWidget);
      await tester.tap(find.byTooltip('Manage Renamed playlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No Playlists'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(manager.tracks, isEmpty);
    },
  );
}
