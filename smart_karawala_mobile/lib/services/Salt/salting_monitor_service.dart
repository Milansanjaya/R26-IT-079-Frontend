import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/salting_monitor_model.dart';

class SaltingMonitorService {
  static const String baseUrl =
      "http://localhost:8001/api/batches";

  static Future<SaltingMonitorModel> getMonitoring(
      String batchId) async {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/$batchId/monitoring",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load monitoring");
    }

    final json = jsonDecode(response.body);

    return SaltingMonitorModel.fromJson(json);
  }
}