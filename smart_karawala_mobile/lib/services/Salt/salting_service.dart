import 'dart:convert';
import 'package:http/http.dart' as http;

class SaltingService {
  static const String baseUrl =
      "http://localhost:8000/api/batches";

  static Future<bool> startSalting(String batchId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$batchId/start-salting"),
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception("Failed to start salting");
  }
}