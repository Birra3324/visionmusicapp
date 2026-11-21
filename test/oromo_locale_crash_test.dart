import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:visionmusicapp/l10n/fallback_localizations.dart';

/// Regression test for the Nov 18 2026 Crashlytics crash: choosing Afaan
/// Oromo left MaterialLocalizations null.
Widget _app(Locale locale, Widget home) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...appLocalizationsFallbackDelegates,
      ],
      home: home,
    );

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('${locale.languageCode}: built-in Flutter strings resolve',
        (tester) async {
      late MaterialLocalizations material;
      late AppLocalizations app;
      await tester.pumpWidget(_app(
        locale,
        Builder(builder: (context) {
          material = MaterialLocalizations.of(context);
          app = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(title: Text(app.home)),
            body: const TextField(),
          );
        }),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(material.backButtonTooltip, isNotEmpty);
      expect(find.text(app.home), findsOneWidget);
    });
  }

  testWidgets('om: app strings stay in Afaan Oromo, Flutter ones fall back',
      (tester) async {
    late String home;
    late String back;
    await tester.pumpWidget(_app(
      const Locale('om'),
      Builder(builder: (context) {
        home = AppLocalizations.of(context)!.home;
        back = MaterialLocalizations.of(context).backButtonTooltip;
        return const SizedBox();
      }),
    ));
    expect(home, isNot(equals('Home')));
    expect(back, 'Back');
  });

  testWidgets('om: dialogs and pickers open without crashing', (tester) async {
    await tester.pumpWidget(_app(
      const Locale('om'),
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const AlertDialog(content: Text('ok')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('ok'), findsOneWidget);
  });
}
