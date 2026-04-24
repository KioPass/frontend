import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyRole = 'userRole';
  static const _keyName = 'userName';
  static const _keyEmail = 'userEmail';
  static const _keyToken = 'authToken';
  static const _keyStoreName = 'storeName';

  static Future<void> saveUser({
    required String role,
    required String name,
    required String email,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    if (token != null) await prefs.setString(_keyToken, token);
  }

  static Future<void> saveStoreName(String storeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoreName, storeName);
  }

  static Future<String?> getStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStoreName);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyRole);
  }

  static Future<bool> isSeller() async {
    final role = await getUserRole();
    return role == 'seller';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}