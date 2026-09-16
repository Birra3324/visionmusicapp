import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/features/auth/login_screen.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';

void main() {
  testWidgets('guest continue stays available when Firebase is not ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginScreen(firebaseReady: false),
      ),
    );

    expect(find.text('Sign in temporarily unavailable'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Vision Music'), findsOneWidget);
  });
}
