import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visionmusicapp/settings_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('settings persist across a re-initialised manager', () async {
    SharedPreferences.setMockInitialValues({});
    final first = SettingsManager();
    await first.init();

    first.autoplay = false;
    first.shuffle = true;
    first.repeatMode = LoopMode.all;
    first.localeCode = 'ar';

    // A fresh prefs store built from what the first manager wrote.
    final prefs = await SharedPreferences.getInstance();
    final second = SettingsManager();
    // Give the singleton a clean read of the same backing store.
    SharedPreferences.setMockInitialValues(
      prefs.getKeys().fold<Map<String, Object>>({}, (acc, k) {
        final v = prefs.get(k);
        if (v != null) acc[k] = v;
        return acc;
      }),
    );
    await second.init();

    expect(second.autoplay, isFalse);
    expect(second.shuffle, isTrue);
    expect(second.repeatMode, LoopMode.all);
    expect(second.localeCode, 'ar');
    expect(second.locale, const Locale('ar'));
  });

  test('defaults are the documented app defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final manager = SettingsManager();
    await manager.init();

    expect(manager.autoplay, isTrue);
    expect(manager.shuffle, isFalse);
    expect(manager.repeatMode, LoopMode.off);
    expect(manager.localeCode, 'en');
  });

  test('Afaan Oromo uses a canonical locale and survives reload', () async {
    SharedPreferences.setMockInitialValues({'localeCode': 'om'});
    final manager = SettingsManager();
    await manager.init();

    expect(manager.localeCode, 'om');
    expect(manager.locale, const Locale('om'));
    expect(manager.locale.countryCode, isNull);
  });

  test('unsupported saved locales safely fall back to English', () async {
    SharedPreferences.setMockInitialValues({'localeCode': 'invalid'});
    final manager = SettingsManager();
    await manager.init();

    expect(manager.localeCode, 'en');
    expect(manager.locale, const Locale('en'));
  });
}
