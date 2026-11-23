import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the last good copy of the CDN's catalog.json on the phone.
///
/// Listeners in Ethiopia are often on slow or patchy mobile data. With a saved
/// copy the app opens with songs even when cdn.visionmusic.et is slow or
/// unreachable, instead of waiting for a timeout and showing an empty catalog.
abstract class CatalogCache {
  Future<String?> read();
  Future<void> write(String body);
}

class SharedPreferencesCatalogCache implements CatalogCache {
  const SharedPreferencesCatalogCache();

  static const String key = 'cdn.catalog.json.v1';

  @override
  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, body);
  }
}

/// In-memory cache for tests.
class MemoryCatalogCache implements CatalogCache {
  MemoryCatalogCache([this.body]);

  String? body;
  int writes = 0;

  @override
  Future<String?> read() async => body;

  @override
  Future<void> write(String value) async {
    body = value;
    writes++;
  }
}
