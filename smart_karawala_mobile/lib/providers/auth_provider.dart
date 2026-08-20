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

      await StorageService.saveRole(_user?.role ?? "customer");

      _loading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> googleSignIn({String? idToken}) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await AuthService.googleSignIn(idToken: idToken);

      if (response["access_token"] != null) {
        await StorageService.saveToken(response["access_token"]);
        _user = UserModel.fromJson(response["user"]);
        await StorageService.saveRole(_user?.role ?? "customer");
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

  void logout() async {
    await StorageService.clearToken();

    _user = null;

    notifyListeners();
  }
}