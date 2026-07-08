import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // Windows Chrome
  static const String baseUrl = "http://localhost:8000";

  // Android Emulator
  // static const String baseUrl = "http://10.0.2.2:8000";

  // Physical Phone
  // static const String baseUrl = "http://192.168.1.100:8000";

  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  static Future<dynamic> get(
      String endpoint,
      String token,
      ) async {
    final response = await http.get(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }
}