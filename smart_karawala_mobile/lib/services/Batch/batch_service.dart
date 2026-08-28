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
    final response = await http.post(
      Uri.parse("$baseUrl/$batchId/predict-waste"),
    );

    if (response.statusCode != 200) {
      throw Exception("Prediction failed");
    }
  }

  static Future<Map<String, dynamic>> sendNotificationResult(String batchId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$batchId/send-waste-notification"),
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Notification sent successfully"};
      } else {
        try {
          final body = jsonDecode(response.body);
          final msg = body["detail"] ?? "Failed to send notification.";
          return {"success": false, "message": msg};
        } catch (_) {
          return {"success": false, "message": "Failed to send notification."};
        }
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<bool> sendNotification(String batchId) async {
    final res = await sendNotificationResult(batchId);
    return res["success"] == true;
  }

}


