import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/l10n/app_localizations.dart';

void main() {
  test('Afaan Oromo listener navigation and search strings are generated', () {
    final om = lookupAppLocalizations(const Locale('om'));

    expect(om.home, isNot(equals('Home')));
    expect(om.watch, isNot(equals('Watch')));
    expect(om.library, isNot(equals('Library')));
    expect(om.profile, isNot(equals('Profile')));
    expect(om.searchQuestion, contains('dhaggeeffachuu'));
    expect(om.continueAsGuest, contains('keessummaatti'));
  });

  test('all declared locales contain primary listener strings', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final strings = lookupAppLocalizations(locale);
      expect(
        strings.home.trim(),
        isNotEmpty,
        reason: '${locale.languageCode}: home',
      );
      expect(
        strings.watch.trim(),
        isNotEmpty,
        reason: '${locale.languageCode}: watch',
      );
      expect(
        strings.library.trim(),
        isNotEmpty,
        reason: '${locale.languageCode}: library',
      );
      expect(
        strings.profile.trim(),
        isNotEmpty,
        reason: '${locale.languageCode}: profile',
      );
      expect(
        strings.searchHint.trim(),
        isNotEmpty,
        reason: '${locale.languageCode}: searchHint',
      );
    }
  });
}
