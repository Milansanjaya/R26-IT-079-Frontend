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

  bool get isAdmin => _user?.role == "admin";

  bool get isCustomer => _user?.role == "customer";

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

      if (response["access_token"] == null) {
        _loading = false;
        notifyListeners();
        return false;
      }

      await StorageService.saveToken(
        response["access_token"],
      );

      _user = UserModel.fromJson(
        response["user"],
      );

      if (_user != null) {
        await StorageService.saveRole(_user?.role ?? "customer");
        await StorageService.saveUserInfo(
          name: _user!.fullName,
          email: _user!.email,
          role: _user!.role,
          phone: _user!.phone,
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

  Future<bool> googleSignIn({
    String? idToken,
    String? email,
    String? name,
    String? role,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await AuthService.googleSignIn(
        idToken: idToken,
        email: email,
        name: name,
        role: role,
      );

      if (response["access_token"] != null) {
        await StorageService.saveToken(response["access_token"]);
        _user = UserModel.fromJson(response["user"]);
        await StorageService.saveRole(_user?.role ?? "customer");
        if (_user != null) {
          await StorageService.saveUserInfo(
            name: _user!.fullName,
            email: _user!.email,
            role: _user!.role,
            phone: _user!.phone,
          );
        }
        _loading = false;
        notifyListeners();
        return true;
      }
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadUserFromStorage() async {
    if (_user != null) return;
    final name = await StorageService.getUserName();
    final email = await StorageService.getUserEmail();
    final role = await StorageService.getRole();
    final phone = await StorageService.getUserPhone();

    if (name != null && name.isNotEmpty) {
      _user = UserModel(
        id: "",
        fullName: name,
        email: email ?? "",
        role: role ?? "customer",
        isVerified: true,
        phone: phone,
      );
      notifyListeners();
    }
  }

  void logout() async {
    await StorageService.clearToken();

    _user = null;

    notifyListeners();
  }
}