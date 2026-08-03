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

  
  /// Returns recommended duration formatted string based on cleaned weight (kg).
  ///
  /// - 0 – 100 kg: "12 Hours"
  /// - 101 – 200 kg: "24 Hours"
  /// - 201 – 300 kg: "48 Hours"
  /// - Above 300 kg: "72 Hours"
  static String getRecommendedDuration(double cleanedWeight) {
    if (cleanedWeight <= 100) {
      return "12 Hours";
    } else if (cleanedWeight <= 200) {
      return "24 Hours";
    } else if (cleanedWeight <= 300) {
      return "48 Hours";
    } else {
      return "72 Hours";
    }
  }

  /// Calculates recommended salting duration (in hours) based on cleaned weight (kg).
  static int calculateRecommendedDuration(double cleanedWeight) {
    if (cleanedWeight <= 100) {
      return 12;
    } else if (cleanedWeight <= 200) {
      return 24;
    } else if (cleanedWeight <= 300) {
      return 48;
    } else {
      return 72;
    }
  }

  /// Predict salt and duration based on batch parameters
  static Future<SaltPredictionModel> predictSalt(BatchModel batch) async {
    final double weight = batch.cleanedWeight;
    final int saltingDurationHours = calculateRecommendedDuration(weight);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/${batch.batchId}/predict-salt"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"cleanedWeight": weight}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final returnedWeight = (json["cleanedWeight"] as num?)?.toDouble() ?? weight;
        final calculatedDuration = calculateRecommendedDuration(returnedWeight);

        return SaltPredictionModel(
          batchId: batch.batchId,
          fishType: batch.fishType,
          cleanedWeight: returnedWeight,
          saltAmount: (json["saltAmount"] as num?)?.toDouble() ?? (returnedWeight * 0.25),
          saltingDurationHours: calculatedDuration,
        );
      }
    } catch (_) {
      // Fallback if backend API is offline or throws error
    }

    return SaltPredictionModel(
      batchId: batch.batchId,
      fishType: batch.fishType,
      cleanedWeight: weight,
      saltAmount: weight * 0.25,
      saltingDurationHours: saltingDurationHours,
    );
  }
}
