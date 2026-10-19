import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String tokenKey = "access_token";
  static const String roleKey = "user_role";
  static const String nameKey = "user_name";
  static const String emailKey = "user_email";
  static const String phoneKey = "user_phone";

  /// Save JWT Token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
    } catch (e) {
      // safe fallback
    }
  }

  /// Read JWT Token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Save User Role ('admin' or 'customer')
  static Future<void> saveRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(roleKey, role);
    } catch (e) {
      // safe fallback
    }
  }

  /// Read User Role
  static Future<String?> getRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(roleKey);
    } catch (e) {
      return null;
    }
  }

  /// Save User Profile Info
  static Future<void> saveUserInfo({
    required String name,
    required String email,
    required String role,
    String? phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(nameKey, name);
      await prefs.setString(emailKey, email);
      await prefs.setString(roleKey, role);
      if (phone != null && phone.isNotEmpty) {
        await prefs.setString(phoneKey, phone);
      }
    } catch (e) {
      // safe fallback
    }
  }

  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(nameKey);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(emailKey);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(phoneKey);
    } catch (e) {
      return null;
    }
  }

  /// Delete JWT Token & User Data
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(roleKey);
      await prefs.remove(nameKey);
      await prefs.remove(emailKey);
      await prefs.remove(phoneKey);
    } catch (e) {
      // safe fallback
    }
  }
}