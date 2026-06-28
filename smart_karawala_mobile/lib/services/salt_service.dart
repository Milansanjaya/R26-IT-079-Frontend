import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/batch_model.dart';
import '../models/salt_prediction_model.dart';

class SaltService {
  static const String baseUrl = "http://localhost:8000/api/batches";

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

  
  /// Predict salt
  static Future<SaltPredictionModel> predictSalt(BatchModel batch) async {
    final response = await http.post(
      Uri.parse("$baseUrl/${batch.batchId}/predict-salt"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"cleanedWeight": batch.cleanedWeight}),
    );

    if (response.statusCode != 200) {
      throw Exception("Salt prediction failed");
    }

    final json = jsonDecode(response.body);

    return SaltPredictionModel(
      batchId: batch.batchId,
      fishType: batch.fishType,
      cleanedWeight: (json["cleanedWeight"] as num).toDouble(),
      saltAmount: (json["saltAmount"] as num).toDouble(),
      saltingDurationHours: json["saltingDurationHours"],
    );
  }
}
