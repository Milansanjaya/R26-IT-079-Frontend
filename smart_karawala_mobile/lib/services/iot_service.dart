import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sensor_model.dart';

class IotService {
  static const String baseUrl = "http://127.0.0.1:8002";

  static Future<SensorModel> getLiveData() async {
    final response = await http.get(Uri.parse("$baseUrl/api/iot/live"));
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid sensor response");
    }
    return SensorModel.fromJson(decoded);
  }

  static Future<Map<String, dynamic>> createControlProfile({
    required String batchId,
    required double targetTemperature,
    required double targetHumidity,
    required int targetDurationMinutes,
  }) {
    return _request(
      "POST",
      "/api/iot/control-profiles",
      body: {
        "batch_id": batchId,
        "target_temperature_c": targetTemperature,
        "target_humidity_percent": targetHumidity,
        "predicted_duration_minutes": targetDurationMinutes,
        "profile_version": "mobile-control",
        "source": "operator_override",
      },
      expectedStatus: 201,
    );
  }

  static Future<Map<String, dynamic>> startDryingSession({
    required String batchId,
    required String mode,
  }) {
    return _request(
      "POST",
      "/api/iot/sessions/${Uri.encodeComponent(batchId)}/start",
      body: {"mode": mode},
    );
  }

  static Future<Map<String, dynamic>> stopDryingSession(String batchId) {
    return _request(
      "POST",
      "/api/iot/sessions/${Uri.encodeComponent(batchId)}/stop",
    );
  }

  static Future<Map<String, dynamic>> setManualActuators({
    required String batchId,
    bool? heater,
    bool? fan,
    bool? light,
  }) {
    return _request(
      "PUT",
      "/api/iot/sessions/${Uri.encodeComponent(batchId)}/manual-actuators",
      body: {
        if (heater != null) "heater": heater,
        if (fan != null) "fan": fan,
        if (light != null) "light": light,
      },
    );
  }

  static Future<Map<String, dynamic>> tareScale({String? batchId}) {
    return _request(
      "POST",
      "/api/iot/tare",
      body: {if (batchId != null) "batch_id": batchId},
    );
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    int expectedStatus = 200,
  }) async {
    final uri = Uri.parse("$baseUrl$path");
    final headers = {"Content-Type": "application/json"};
    final encodedBody = body == null ? null : jsonEncode(body);
    final response = switch (method) {
      "POST" => await http.post(uri, headers: headers, body: encodedBody),
      "PUT" => await http.put(uri, headers: headers, body: encodedBody),
      _ => throw ArgumentError("Unsupported HTTP method: $method"),
    };

    if (response.statusCode != expectedStatus) {
      throw Exception(_errorMessage(response));
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid backend response");
    }
    return decoded;
  }

  static String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded["detail"] != null) {
        return decoded["detail"].toString();
      }
    } catch (_) {
      // Use the status when the response is not JSON.
    }
    return "Request failed (${response.statusCode})";
  }
}
