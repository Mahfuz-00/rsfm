import 'package:shared_preferences/shared_preferences.dart';

class CredentialStorage {
  static const _urlKey = 'rsfm_url';
  static const _passwordKey = 'rsfm_password';

  static Future<void> save(String url, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url);
    await prefs.setString(_passwordKey, password);
  }

  static Future<Map<String, String>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_urlKey);
    final password = prefs.getString(_passwordKey);
    if (url != null && password != null) {
      return {'url': url, 'password': password};
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_urlKey);
    await prefs.remove(_passwordKey);
  }
}