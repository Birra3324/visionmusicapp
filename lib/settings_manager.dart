import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager extends ChangeNotifier {
  static const supportedLocaleCodes = {'en', 'om', 'am', 'ar', 'fr', 'es'};

  static final SettingsManager instance = SettingsManager._internal();
  factory SettingsManager() => instance;
  SettingsManager._internal();

  late SharedPreferences _prefs;

  // Backwards-compatible alias for existing code
  SettingsManager get settings => this;

  // ------- Stored values (with defaults) -------
  bool _autoplay = true;
  bool _shuffle = false;
  LoopMode _repeatMode = LoopMode.off;
  String _localeCode = 'en'; // Language code (en, om, am, ar, fr, es)

  bool get autoplay => _autoplay;
  bool get shuffle => _shuffle;
  LoopMode get repeatMode => _repeatMode;
  String get localeCode => _localeCode;
  Locale get locale => Locale(_localeCode);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _autoplay = _prefs.getBool('autoplay') ?? true;
    _shuffle = _prefs.getBool('shuffle') ?? false;
    _repeatMode =
        LoopMode.values[_prefs.getInt('repeatMode') ?? LoopMode.off.index];
    final savedLocale = _prefs.getString('localeCode') ?? 'en';
    _localeCode = supportedLocaleCodes.contains(savedLocale)
        ? savedLocale
        : 'en';

    notifyListeners();
  }

  // ------- Setters (save + notify) -------

  set autoplay(bool value) {
    _autoplay = value;
    _prefs.setBool('autoplay', value);
    notifyListeners();
  }

  set shuffle(bool value) {
    _shuffle = value;
    _prefs.setBool('shuffle', value);
    notifyListeners();
  }

  set repeatMode(LoopMode mode) {
    _repeatMode = mode;
    _prefs.setInt('repeatMode', mode.index);
    notifyListeners();
  }

  set localeCode(String code) {
    if (!supportedLocaleCodes.contains(code) || code == _localeCode) return;
    _localeCode = code;
    _prefs.setString('localeCode', code);
    notifyListeners();
  }
}
