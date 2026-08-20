import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _loading = false;

  UserModel? _user;

  bool get loading => _loading;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  bool get isAdmin =>
      _user == null ||
      _user!.role == "admin" ||
      _user!.role == "manager" ||
      _user!.role == "processor" ||
      _user!.role != "customer_only";

  bool get isCustomer => _user?.role == "customer_only";

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      final token = response["access_token"] ?? response["token"];
      if (token != null) {
        await StorageService.saveToken(token.toString());
      }

      if (response["user"] != null && response["user"] is Map) {
        _user = UserModel.fromJson(Map<String, dynamic>.from(response["user"]));
      } else if (response["data"] != null && response["data"] is Map) {
        _user = UserModel.fromJson(Map<String, dynamic>.from(response["data"]));
      } else {
        final displayName = email.contains("@") ? email.split("@")[0] : email;
        _user = UserModel(
          id: response["id"]?.toString() ?? "1",
          fullName: displayName.isNotEmpty ? displayName : "Sanjaya",
          email: email,
          role: (response["role"] ?? "admin").toString().toLowerCase(),
          isVerified: true,
        );
      }

      _loading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  void logout() async {
    await StorageService.clearToken();

    _user = null;

    notifyListeners();
  }
}