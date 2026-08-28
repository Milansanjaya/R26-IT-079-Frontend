import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/salting_monitor_model.dart';
import 'salt_service.dart';

class SaltingMonitorService {


  static Future<SaltingMonitorModel> getMonitoring(String batchId) async {
    try {
      final response = await http.get(
        Uri.parse("${SaltService.baseUrl}/$batchId/monitoring"),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SaltingMonitorModel.fromJson(json);
      }
    } catch (_) {}

    double cleanedWeight = 0.1;
    String fishType = "Linna";
    try {
      final batch = batchId.isNotEmpty
          ? await SaltService.getBatchById(batchId)
          : await SaltService.getLatestBatch();
      cleanedWeight = batch.cleanedWeight > 0
          ? batch.cleanedWeight
          : (batch.rawWeight > 0 ? (batch.rawWeight - batch.predictedWaste) : 0.1);
      if (cleanedWeight <= 0) cleanedWeight = 0.1;
      fishType = batch.fishType;
    } catch (_) {}

    final totalHours = SaltService.calculateRecommendedDuration(cleanedWeight, fishType).toDouble();
    final saltRatio = SaltService.getSaltRatio(fishType);
    final saltAmount = cleanedWeight * saltRatio;

    return SaltingMonitorModel(
      batchId: batchId.isNotEmpty ? batchId : "BATCH-178576",
      fishType: fishType,
      status: "In Progress",
      startTime: "2026-08-22 12:00",
      progress: 0.0,
      cleanedWeight: cleanedWeight,
      currentWeight: cleanedWeight,
      weightLoss: 0.0,
      weightLossPercentage: 0.0,
      remainingHours: totalHours,
    );
  }
}
