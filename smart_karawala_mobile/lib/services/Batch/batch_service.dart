import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/batch_model.dart';

class BatchService {
  static const String baseUrl = "http://localhost:8001/api/batches";

  static Future<List<BatchModel>> getBatches() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List batches = json["batches"];

      return batches.map((e) => BatchModel.fromJson(e)).toList();
    }

    throw Exception("Cannot load batches");
  }

  static Future<BatchModel> getLatestBatch() async {
    final batches = await getBatches();

    return batches.first;
  }

  static Future<BatchModel> getBatchById(String batchId) async {
    try {
      final batches = await getBatches();
      final found = batches.firstWhere(
        (b) => b.batchId == batchId,
        orElse: () => batches.first,
      );
      return found;
    } catch (_) {}
    return getLatestBatch();
  }

  static Future<void> predictWaste(String batchId) async {
    try {
      await http
          .post(Uri.parse("$baseUrl/$batchId/predict-waste"))
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  static Future<bool> sendNotification(String batchId) async {
    try {
      final response = await http
          .post(Uri.parse("$baseUrl/$batchId/send-waste-notification"))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}


