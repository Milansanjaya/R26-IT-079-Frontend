import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data["detail"] ?? data["message"] ?? "Something went wrong");
    }
  }

  static Future<Map<String, dynamic>> get(
    String endpoint,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data["detail"] ?? "Something went wrong");
    }
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
}