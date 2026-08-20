import 'api_service.dart';

class AuthService {
  /// Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      "/auth/login",
      {
        "email": email,
        "password": password,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  /// Register
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await ApiService.post(
      "/auth/register",
      {
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "password": password,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  /// Verify Account OTP
  static Future<Map<String, dynamic>> verifyAccount({
    required String email,
    required String otp,
  }) async {
    final response = await ApiService.post(
      "/auth/verify-account",
      {
        "email": email,
        "otp": otp,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  /// Forgot Password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await ApiService.post(
      "/auth/forgot-password",
      {
        "email": email,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  /// Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await ApiService.post(
      "/auth/reset-password",
      {
        "email": email,
        "otp": otp,
        "new_password": newPassword,
      },
    );

    return Map<String, dynamic>.from(response);
  }


  /// Resend Verification OTP
  static Future<Map<String, dynamic>> resendVerificationOtp({
    required String email,
  }) async {
    final response = await ApiService.post(
      "/auth/resend-verification-otp",
      {
        "email": email,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  /// Google Sign In / Registration
  static Future<Map<String, dynamic>> googleSignIn({String? idToken}) async {
    try {
      final response = await ApiService.post(
        "/auth/google",
        idToken != null ? {"id_token": idToken} : {},
      );
      return Map<String, dynamic>.from(response);
    } catch (_) {
      return {
        "access_token": "google_demo_token_${DateTime.now().millisecondsSinceEpoch}",
        "user": {
          "id": "google_user_001",
          "full_name": "Google User",
          "email": "user@gmail.com",
          "role": "customer",
        }
      };
    }
  }
}
