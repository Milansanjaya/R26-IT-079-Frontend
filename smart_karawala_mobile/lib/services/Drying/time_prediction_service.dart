import 'dart:convert';
import 'package:http/http.dart' as http;

class TimePredictionService {
  static const String baseUrl = 'http://localhost:8003/api/predict';

  /// Predicts both the recommended drying temperature and the total drying
  /// time for a batch, before drying starts. Backed by a trained ML model
  /// (POST /api/predict/initial) — falls back server-side to a rule-based
  /// estimate if the model can't be loaded.
  static Future<Map<String, dynamic>> predictInitial({
    required String fishType,
    required double initialWeightKg,
    required double humidityPercent,
    double mq136Value = 0.0,
  }) async {
    final payload = {
      'fish_type': fishType.trim().toLowerCase(),
      'initial_weight_kg': initialWeightKg,
      'humidity_percent': humidityPercent,
      'mq136_value': mq136Value,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/initial'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded as Map<String, dynamic>;
    }

    final detail = decoded is Map<String, dynamic>
        ? (decoded['detail'] ?? decoded['error'] ?? 'Prediction failed')
        : 'Prediction failed';
    throw Exception(detail.toString());
  }
}
