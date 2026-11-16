import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';

/// Keep the app's translations for every advertised language.
/// Common Oromo framework controls are translated below. Unused framework
/// surfaces retain English until the app needs a full custom locale delegate.
const visionLocalizationDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  _MaterialFallback(),
  _CupertinoFallback(),
  _WidgetsFallback(),
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

class _MaterialFallback extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialFallback();
  @override
  bool isSupported(Locale locale) =>
      !GlobalMaterialLocalizations.delegate.isSupported(locale);
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      locale.languageCode == 'om'
      ? SynchronousFuture<MaterialLocalizations>(const _OromoMaterial())
      : GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  @override
  bool shouldReload(_MaterialFallback old) => false;
}

class _CupertinoFallback extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoFallback();
  @override
  bool isSupported(Locale locale) =>
      !GlobalCupertinoLocalizations.delegate.isSupported(locale);
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      locale.languageCode == 'om'
      ? SynchronousFuture<CupertinoLocalizations>(const _OromoCupertino())
      : GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  @override
  bool shouldReload(_CupertinoFallback old) => false;
}

class _WidgetsFallback extends LocalizationsDelegate<WidgetsLocalizations> {
  const _WidgetsFallback();
  @override
  bool isSupported(Locale locale) =>
      !GlobalWidgetsLocalizations.delegate.isSupported(locale);
  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('en'));
  @override
  bool shouldReload(_WidgetsFallback old) => false;
}

// Common framework controls used by listener screens. Unused framework surfaces
// (for example date pickers) retain the documented English fallback.
class _OromoMaterial extends DefaultMaterialLocalizations {
  const _OromoMaterial();
  @override
  String get backButtonTooltip => "Duubatti deebi'i";
  @override
  String get closeButtonTooltip => 'Cufi';
  @override
  String get cancelButtonLabel => 'Dhiisi';
  @override
  String get okButtonLabel => 'Tole';
  @override
  String get deleteButtonTooltip => 'Haqi';
  @override
  String get copyButtonLabel => 'Garagalchi';
  @override
  String get cutButtonLabel => 'Muri';
  @override
  String get pasteButtonLabel => 'Maxxansi';
  @override
  String get selectAllButtonLabel => 'Hunda filadhu';
  @override
  String get modalBarrierDismissLabel => 'Cufi';
  @override
  String get popupMenuLabel => 'Baafata';
  @override
  String get showMenuTooltip => 'Baafata agarsiisi';
  @override
  String get searchFieldLabel => 'Barbaadi';
}

class _OromoCupertino extends DefaultCupertinoLocalizations {
  const _OromoCupertino();
  @override
  String get copyButtonLabel => 'Garagalchi';
  @override
  String get cutButtonLabel => 'Muri';
  @override
  String get pasteButtonLabel => 'Maxxansi';
  @override
  String get selectAllButtonLabel => 'Hunda filadhu';
  @override
  String get modalBarrierDismissLabel => 'Cufi';
}
