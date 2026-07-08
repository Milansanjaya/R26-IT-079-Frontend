import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/processing_report_model.dart';

class ProcessingReportService {
  static const String baseUrl =
      "http://localhost:8000/api/batches";

  static Future<List<ProcessingReportModel>> getReports() async {
    final response = await http.get(
      Uri.parse("$baseUrl/reports"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load reports");
    }

    final json = jsonDecode(response.body);

    final List reports = json["reports"];

    return reports
        .map((e) => ProcessingReportModel.fromJson(e))
        .toList();
  }
  static Future<void> deleteBatch(String batchId) async {
  final response = await http.delete(
    Uri.parse("$baseUrl/$batchId"),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to delete batch");
  }
}
static Future<void> updateBatch({
  required String batchId,
  required String fishType,
  required double rawWeight,
  required String status,
}) async {

  final response = await http.put(
    Uri.parse("$baseUrl/$batchId"),

    headers: {
      "Content-Type": "application/json",
    },

    body: jsonEncode({
      "fishType": fishType,
      "rawWeight": rawWeight,
      "status": status,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to update batch");
  }
}

}