import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/drying_model.dart';

/// HTTP client for the Drying integration routes exposed by the
/// TimeAndSpoilagePredictionService (`/api/drying/*`, port 8003).
///
/// Only ONE batch is dried at a time, so the "active" endpoints do not need a
/// batchId — the backend tracks the current active drying batch internally.
class DryingService {
  static const String baseUrl = "http://localhost:8003/api/drying";

  // Jayani's batch service owns the batch list (used to find the batch that
  // was just placed in the oven). Kept here so the Drying module is
  // self-contained and doesn't depend on other feature services.
  static const String batchListUrl = "http://localhost:8001/api/batches";

  static const Duration _timeout = Duration(seconds: 15);

  /// Whether a batch has finished salting (salting + keeping complete).
  /// Reads Jayani's batch record `saltingStatus`. Matches "completed"/"complete"
  /// case-insensitively; anything else (not_started / in progress) is not ready.
  static Future<bool> isSaltingCompleted(String batchId) async {
    final response = await http
        .get(Uri.parse("$batchListUrl/$batchId"))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      // If we can't tell, don't block — surface via the start call instead.
      return false;
    }
    final json = _decode(response);
    final batch = json["batch"];
    final status = (batch is Map ? batch["saltingStatus"] : null)
            ?.toString()
            .trim()
            .toLowerCase() ??
        "";
    return status.startsWith("complete");
  }

  /// Find the most recently created batch (the one placed in the oven).
  static Future<String> getLatestBatchId() async {
    final response =
        await http.get(Uri.parse(batchListUrl)).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception("Couldn't load batches (HTTP ${response.statusCode})");
    }

    final json = _decode(response);
    final batches = json["batches"];
    if (batches is! List || batches.isEmpty) {
      throw Exception("No batches available to dry yet");
    }

    final first = batches.first;
    final id = (first is Map) ? first["batchId"]?.toString() : null;
    if (id == null || id.isEmpty) {
      throw Exception("Latest batch has no batchId");
    }
    return id;
  }

  /// Start drying a batch — snapshots it as the single active drying batch.
  ///
  /// [initialTemperatureC] / [initialTotalHours] are the recommended
  /// temperature and total drying time from the pre-drying prediction
  /// (TimePredictionService.predictInitial), if that step ran first. They
  /// seed the countdown shown before live sensor data can produce a
  /// meaningful re-estimate.
  /// [ovenSessionId] is the id the oven session was actually opened under. It
  /// usually equals [batchId], but differs when the batch's own oven session
  /// is in a terminal state and a fresh suffixed id had to be used.
  static Future<ActiveDryingBatch> startDrying(
    String batchId, {
    double? initialTemperatureC,
    double? initialTotalHours,
    String? ovenSessionId,
  }) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/start"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "batchId": batchId,
            if (initialTemperatureC != null) "initialTemperatureC": initialTemperatureC,
            if (initialTotalHours != null) "initialTotalHours": initialTotalHours,
            if (ovenSessionId != null) "ovenSessionId": ovenSessionId,
          }),
        )
        .timeout(_timeout);

    final json = _decode(response);

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(json) ?? "Failed to start drying");
    }

    // /start returns the same fields as /active (minus elapsed), so reuse it.
    return ActiveDryingBatch.fromJson(json);
  }

  /// Get the current active drying batch (404 -> null, meaning none active).
  static Future<ActiveDryingBatch?> getActiveBatch() async {
    final response =
        await http.get(Uri.parse("$baseUrl/active")).timeout(_timeout);

    if (response.statusCode == 404) return null;

    final json = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(json) ?? "Failed to load active batch");
    }
    return ActiveDryingBatch.fromJson(json);
  }

  /// Predict remaining drying time for the active batch (uses live sensors).
  static Future<DryingTimeResult> getDryingTime() async {
    final response = await http
        .get(Uri.parse("$baseUrl/active/drying-time"))
        .timeout(_timeout);

    final json = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(json) ?? "Failed to predict drying time");
    }
    return DryingTimeResult.fromJson(json);
  }

  /// Classify spoilage risk for the active batch (uses live sensors).
  static Future<SpoilageRiskResult> getSpoilageRisk() async {
    final response = await http
        .get(Uri.parse("$baseUrl/active/spoilage-risk"))
        .timeout(_timeout);

    final json = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(json) ?? "Failed to classify spoilage risk");
    }
    return SpoilageRiskResult.fromJson(json);
  }

  /// Stop drying — clears the active batch pointer.
  static Future<void> stopDrying() async {
    await http.post(Uri.parse("$baseUrl/stop")).timeout(_timeout);
  }

  // ---- helpers -----------------------------------------------------------
  static Map<String, dynamic> _decode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  /// The backend wraps errors as {"success": false, "detail": "..."}.
  static String? _errorMessage(Map<String, dynamic> json) {
    final detail = json["detail"];
    if (detail is String && detail.isNotEmpty) return detail;
    final error = json["error"];
    if (error is String && error.isNotEmpty) return error;
    return null;
  }
}
