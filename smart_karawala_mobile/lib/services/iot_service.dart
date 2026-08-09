import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sensor_model.dart';

class IotService {
  static const String baseUrl = "http://127.0.0.1:8002";

  // ============================================================
  // GET LIVE SENSOR DATA
  // ============================================================

  static Future<SensorModel> getLiveData() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/iot/live"),
    );

    print("LIVE STATUS: ${response.statusCode}");
    print("LIVE RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load live sensor data",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        "Invalid sensor response",
      );
    }

    return SensorModel.fromJson(decoded);
  }

  // ============================================================
  // SEND DEVICE / DRYING COMMAND
  // ============================================================

  static Future<Map<String, dynamic>> sendCommand(
    String command,
  ) async {
    print("=================================");
    print("SENDING COMMAND: $command");
    print("=================================");

    final response = await http.post(
      Uri.parse("$baseUrl/api/iot/command"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "command": command,
      }),
    );

    print("COMMAND: $command");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Command failed: ${response.statusCode}",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        "Invalid command response",
      );
    }

    return decoded;
  }

  // ============================================================
  // GET DRYING STATUS
  //
  // Backend:
  // GET /api/iot/drying-status
  //
  // Example:
  // {
  //   "drying_running": true,
  //   "drying_mode": "AUTO"
  // }
  // ============================================================

  static Future<Map<String, dynamic>> getDryingStatus() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/iot/drying-status"),
    );

    print(
      "DRYING STATUS CODE: ${response.statusCode}",
    );

    print(
      "DRYING STATUS RESPONSE: ${response.body}",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load drying status",
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        "Invalid drying status response",
      );
    }

    return decoded;
  }

  // ============================================================
  // START AUTO DRYING
  // ============================================================

  static Future<Map<String, dynamic>>
      startAutoDrying() async {
    return sendCommand(
      "start_auto_drying",
    );
  }

  // ============================================================
  // START MANUAL DRYING
  // ============================================================

  static Future<Map<String, dynamic>>
      startManualDrying() async {
    return sendCommand(
      "start_manual_drying",
    );
  }

  // ============================================================
  // STOP DRYING
  // ============================================================

  static Future<Map<String, dynamic>>
      stopDrying() async {
    return sendCommand(
      "stop_drying",
    );
  }

  // ============================================================
  // HEATER
  // ============================================================

  static Future<Map<String, dynamic>>
      heaterOn() async {
    return sendCommand(
      "heater_on",
    );
  }

  static Future<Map<String, dynamic>>
      heaterOff() async {
    return sendCommand(
      "heater_off",
    );
  }

  // ============================================================
  // EXHAUST FAN
  // ============================================================

  static Future<Map<String, dynamic>>
      fanOn() async {
    return sendCommand(
      "fan_on",
    );
  }

  static Future<Map<String, dynamic>>
      fanOff() async {
    return sendCommand(
      "fan_off",
    );
  }

  // ============================================================
  // LIGHT
  // ============================================================

  static Future<Map<String, dynamic>>
      lightOn() async {
    return sendCommand(
      "light_on",
    );
  }

  static Future<Map<String, dynamic>>
      lightOff() async {
    return sendCommand(
      "light_off",
    );
  }

  // ============================================================
  // TARE / RESET WEIGHT
  // ============================================================

  static Future<Map<String, dynamic>>
      tare() async {
    return sendCommand(
      "tare",
    );
  }
}