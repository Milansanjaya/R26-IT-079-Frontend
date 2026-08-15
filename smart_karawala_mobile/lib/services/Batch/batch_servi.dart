import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/batch_model.dart';

class BatchService {
  static const String baseUrl =
      "http://localhost:8000/api/batches";

  //----------------------------
  // Get All
  //----------------------------

  static Future<List<BatchModel>> getAllBatches() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception("Failed to load batches");
    }

    final List jsonData = jsonDecode(response.body);

    return jsonData
        .map((e) => BatchModel.fromJson(e))
        .toList();
  }

  //----------------------------
  // Update
  //----------------------------

  static Future<void> updateBatch(
    String batchId,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$batchId"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update batch");
    }
  }

  //----------------------------
  // Delete
  //----------------------------

  static Future<void> deleteBatch(String batchId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$batchId"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete batch");
    }
  }
}