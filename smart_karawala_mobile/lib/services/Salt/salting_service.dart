import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

class SaltingService {
  static String get baseUrl => AppConfig.batchesBaseUrl;

  static Future<bool> startSalting(String batchId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$batchId/start-salting"),
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception("Failed to start salting");
  }

  static Future<bool> completeSalting(String batchId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$batchId/complete-salting"),
    );

    if (response.statusCode == 200) {
      return true;
    }

    final decoded = jsonDecode(response.body);
    final detail = decoded is Map<String, dynamic>
        ? (decoded['detail'] ?? 'Failed to complete salting')
        : 'Failed to complete salting';
    throw Exception(detail.toString());
  }
}