import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/profile/profile_hub_screen.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';
import 'package:visionmusicapp/l10n/fallback_localizations.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...appLocalizationsFallbackDelegates,
  ],
  home: Scaffold(body: child),
);

void main() {
  testWidgets('guests see the privacy policy but no account actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const AccountPrivacySection(signedIn: false)),
    );
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Delete my account'), findsNothing);
    expect(find.text('Sign out'), findsNothing);
  });

  testWidgets('signed-in listeners can sign out or delete their account', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const AccountPrivacySection(signedIn: true)));
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Delete my account'), findsOneWidget);
  });

  testWidgets('delete asks first, and Cancel deletes nothing', (tester) async {
    await tester.pumpWidget(_wrap(const AccountPrivacySection(signedIn: true)));
    await tester.tap(find.byKey(const Key('deleteAccountTile')));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsNothing);
    expect(find.text('Delete my account'), findsOneWidget);
  });

  testWidgets('works in Afaan Oromo', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AccountPrivacySection(signedIn: true),
        locale: const Locale('om'),
      ),
    );
    await tester.tap(find.byKey(const Key('deleteAccountTile')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Herrega kee haquu?'), findsOneWidget);
  });

  test('every language has the new account strings', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final s = lookupAppLocalizations(locale);
      for (final value in [
        s.accountAndPrivacy,
        s.privacyPolicy,
        s.signOut,
        s.deleteAccount,
        s.deleteAccountConfirmTitle,
        s.deleteAccountConfirmBody,
        s.deleteAccountConfirmAction,
        s.cancel,
        s.accountDeleted,
        s.deleteAccountFailed,
      ]) {
        expect(value.trim(), isNotEmpty, reason: locale.languageCode);
      }
    }
  });
}
