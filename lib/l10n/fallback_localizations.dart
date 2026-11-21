import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter ships built-in strings (back buttons, dialogs, text-field menus,
/// date pickers) for many languages, but not for Afaan Oromo ('om').
///
/// Without these delegates, choosing Afaan Oromo leaves
/// `MaterialLocalizations.of(context)` null and the app crashes with a
/// "Null check operator used on a null value" error from
/// `material_localizations.dart` (Crashlytics, Nov 18 2026).
///
/// The app's own strings still come from [AppLocalizations] in Oromo. Only
/// Flutter's built-in labels fall back to English for languages it lacks.
const _fallbackLocale = Locale('en');

bool _needsFallback(Locale locale, Set<String> supported) =>
    !supported.contains(locale.languageCode);

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      _needsFallback(locale, kMaterialSupportedLanguages);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(_fallbackLocale);

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      _needsFallback(locale, kCupertinoSupportedLanguages);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(_fallbackLocale);

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      _needsFallback(locale, kWidgetsSupportedLanguages);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(_fallbackLocale);

  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}

/// Delegates for [MaterialApp.localizationsDelegates]: the app's own strings,
/// Flutter's built-in strings, and English fallbacks for languages Flutter
/// does not cover (Afaan Oromo).
const appLocalizationsFallbackDelegates = <LocalizationsDelegate<dynamic>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  FallbackMaterialLocalizationsDelegate(),
  FallbackWidgetsLocalizationsDelegate(),
  FallbackCupertinoLocalizationsDelegate(),
];
