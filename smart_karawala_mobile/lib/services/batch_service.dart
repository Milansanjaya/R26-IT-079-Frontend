import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/batch_model.dart';

class BatchService {
  static const String baseUrl = "http://localhost:8000/api/batches";

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

  static Future<void> predictWaste(String batchId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$batchId/predict-waste"),
    );

    if (response.statusCode != 200) {
      throw Exception("Prediction failed");
    }
  }

  static Future<bool> sendNotification(String batchId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$batchId/send-waste-notification"),
    );

    return response.statusCode == 200;
  }

}


