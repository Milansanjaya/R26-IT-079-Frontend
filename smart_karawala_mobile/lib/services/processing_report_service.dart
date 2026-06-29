import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/processing_report_model.dart';

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
}