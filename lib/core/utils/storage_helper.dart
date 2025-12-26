import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // Specific helper methods for app data
  static Future<bool> saveToken(String token) async {
    return await setString('auth_token', token);
  }

  static String? getToken() {
    return getString('auth_token');
  }

  static Future<bool> saveUserData(String userData) async {
    return await setString('user_data', userData);
  }

  static String? getUserData() {
    return getString('user_data');
  }

  static Future<bool> clearAuth() async {
    await remove('auth_token');
    await remove('user_data');
    return true;
  }
}



