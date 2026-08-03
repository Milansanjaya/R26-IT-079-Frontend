import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/salting_monitor_model.dart';
import 'salt_service.dart';

class SaltingMonitorService {
  static const String baseUrl = "http://localhost:8001/api/batches";

  static Future<SaltingMonitorModel> getMonitoring(String batchId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$batchId/monitoring"),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SaltingMonitorModel.fromJson(json);
      }
    } catch (_) {}

    double cleanedWeight = 85.0;
    try {
      final batch = await SaltService.getLatestBatch();
      cleanedWeight = batch.cleanedWeight;
    } catch (_) {}

    final totalHours = SaltService.calculateRecommendedDuration(cleanedWeight).toDouble();

    return SaltingMonitorModel(
      batchId: batchId.isNotEmpty ? batchId : "BATCH-178576",
      fishType: "Hurulla",
      status: "In Progress",
      startTime: "2026-08-03 20:21",
      progress: 0.0,
      currentWeight: cleanedWeight,
      weightLoss: 0.0,
      weightLossPercentage: 0.0,
      remainingHours: totalHours,
    );
  }
}