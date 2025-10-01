import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _key = 'accessToken';

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> save(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, token);
    }
  }
}
