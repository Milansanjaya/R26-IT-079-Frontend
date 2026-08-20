import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String tokenKey = "access_token";
  static const String roleKey = "user_role";

  /// Save JWT Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Read JWT Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Save User Role ('admin' or 'customer')
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(roleKey, role);
  }

  /// Read User Role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey);
  }

  /// Delete JWT Token & Role
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(roleKey);
  }
}