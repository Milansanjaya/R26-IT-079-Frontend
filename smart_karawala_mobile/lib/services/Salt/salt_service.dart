import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/batch_model.dart';
import '../../models/salt_prediction_model.dart';

class SaltService {
  static const String baseUrl = "http://localhost:8001/api/batches";

  /// Get latest batch
  static Future<BatchModel> getLatestBatch() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to load batches");
    }

    final json = jsonDecode(response.body);

    final List batches = json["batches"];

    if (batches.isEmpty) {
      throw Exception("No batches found");
    }

    return BatchModel.fromJson(batches.first);
  }

  
  /// Returns recommended duration formatted string based on cleaned weight (kg) & fishType.
  static String getRecommendedDuration(double cleanedWeight, [String? fishType]) {
    final hours = calculateRecommendedDuration(cleanedWeight, fishType);
    return "$hours Hours";
  }

  /// Calculates recommended salting duration (in hours) based on cleaned weight (kg) & fishType.
  static int calculateRecommendedDuration(double cleanedWeight, [String? fishType]) {
    final type = fishType?.trim() ?? "";
    if (type == "Thalapath" || type == "Thora" || type == "Mora" || type == "Paraw" || type == "Balaya") {
      if (cleanedWeight <= 0.5) return 8;
      if (cleanedWeight <= 1.5) return 12;
      if (cleanedWeight <= 3.0) return 18;
      return 24;
    } else if (type == "Salaya" || type == "Kumbalawa" || type == "Kelawalla" || type == "Linna" || type == "Hurulla" || type == "Sprats" || type == "Sardine" || type == "Anchovy") {
      if (cleanedWeight <= 0.5) return 4;
      if (cleanedWeight <= 1.5) return 6;
      if (cleanedWeight <= 3.0) return 8;
      return 12;
    } else {
      if (cleanedWeight <= 0.5) return 6;
      if (cleanedWeight <= 1.5) return 8;
      if (cleanedWeight <= 3.0) return 12;
      return 16;
    }
  }

  /// Predict salt and duration based on batch parameters
  static Future<SaltPredictionModel> predictSalt(BatchModel batch) async {
    final double weight = batch.cleanedWeight;
    final int fallbackDuration = calculateRecommendedDuration(weight, batch.fishType);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/${batch.batchId}/predict-salt"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"cleanedWeight": weight}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final returnedWeight = (json["cleanedWeight"] as num?)?.toDouble() ?? weight;
        final returnedDuration = (json["saltingDurationHours"] as num?)?.toInt() ??
            (json["recommendedDuration"] as num?)?.toInt() ??
            calculateRecommendedDuration(returnedWeight, batch.fishType);

        return SaltPredictionModel(
          batchId: batch.batchId,
          fishType: batch.fishType,
          cleanedWeight: returnedWeight,
          saltAmount: (json["saltAmount"] as num?)?.toDouble() ?? (returnedWeight * 0.18),
          saltingDurationHours: returnedDuration,
        );
      }
    } catch (_) {
      // Fallback if backend API is offline or throws error
    }

    return SaltPredictionModel(
      batchId: batch.batchId,
      fishType: batch.fishType,
      cleanedWeight: weight,
      saltAmount: weight * 0.18,
      saltingDurationHours: fallbackDuration,
    );
  }
}
