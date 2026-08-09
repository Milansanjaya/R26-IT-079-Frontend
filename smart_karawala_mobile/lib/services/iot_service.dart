import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/sensor_model.dart';

class IotService {
  static const String baseUrl = "http://127.0.0.1:8002";

  /// Get Live Sensor Data
  static Future<SensorModel> getLiveData() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/iot/live"),
    );

    print("Status Code: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      return SensorModel.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception("Failed to load sensor data");
    }
  }

  /// Send Command to Arduino
  static Future<Map<String, dynamic>> sendCommand(
      String command) async {

    final response = await http.post(
      Uri.parse("$baseUrl/api/iot/command"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "command": command,
      }),
    );

    print("Command: $command");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to send command");
    }
  }
}