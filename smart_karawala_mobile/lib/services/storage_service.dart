import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String tokenKey = "access_token";
  static const String roleKey = "user_role";
  static const String nameKey = "user_name";
  static const String emailKey = "user_email";
  static const String phoneKey = "user_phone";

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

  /// Save User Profile Info
  static Future<void> saveUserInfo({
    required String name,
    required String email,
    required String role,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(nameKey, name);
    await prefs.setString(emailKey, email);
    await prefs.setString(roleKey, role);
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString(phoneKey, phone);
    }
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(nameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailKey);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(phoneKey);
  }

  /// Delete JWT Token & User Data
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(roleKey);
    await prefs.remove(nameKey);
    await prefs.remove(emailKey);
    await prefs.remove(phoneKey);
  }
}