import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/traceability_dashboard_model.dart';

class TraceabilityService {
  static const String baseUrl = "http://localhost:8001/api/batches";

  static Future<TraceabilityDashboardModel> getDashboard() async {
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard"));

    print("Status Code: ${response.statusCode}");
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception("Failed to load dashboard");
    }

    final json = jsonDecode(response.body);

    return TraceabilityDashboardModel.fromJson(json);
  }
}
