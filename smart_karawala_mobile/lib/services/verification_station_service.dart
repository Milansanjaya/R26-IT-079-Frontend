import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/telemetry_model.dart';

class VerificationStationService {
  static String stationHost = "http://localhost:3000";

  // Simulated telemetry state for fallback when hardware server is offline
  static TelemetryData _simulatedData = TelemetryData(
    temperatureC: 34.2,
    temperatureF: 93.56,
    humidityPercent: 48.0,
    gasRaw: 280.0,
    loadCellRaw: 1250.0,
    heaterState: false,
    lightState: true,
    fanState: true,
  );

  /// Get Camera Stream URL
  static String getStreamUrl({String? host}) {
    final baseUrl = host ?? stationHost;
    return "$baseUrl/api/camera/stream";
  }

  /// Get Telemetry Data from Verification Station API
  static Future<TelemetryData> fetchTelemetry({String? host}) async {
    final baseUrl = host ?? stationHost;
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/api/camera/telemetry"))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('telemetry') && data['telemetry'] != null) {
          return TelemetryData.fromJson(Map<String, dynamic>.from(data['telemetry']));
        }
        return TelemetryData.fromJson(data);
      }
    } catch (_) {
      // Hardware/Server offline - return dynamic simulated telemetry
    }

    // Dynamic variation for simulated mode
    final random = Random();
    final tempDelta = (random.nextDouble() - 0.5) * 0.4;
    final humidityDelta = (random.nextDouble() - 0.5) * 0.6;
    final gasDelta = (random.nextDouble() - 0.5) * 4;

    _simulatedData = _simulatedData.copyWith(
      temperatureC: double.parse((_simulatedData.temperatureC + tempDelta).toStringAsFixed(1)),
      humidityPercent: double.parse((_simulatedData.humidityPercent + humidityDelta).toStringAsFixed(1)),
      gasRaw: double.parse((_simulatedData.gasRaw + gasDelta).toStringAsFixed(0)),
    );

    return _simulatedData;
  }

  /// Send Actuator Control Command (light_on, light_off, heater_on, heater_off, fan_on, fan_off, tare)
  static Future<bool> sendControlAction(String action, {String? host}) async {
    final baseUrl = host ?? stationHost;

    // Update local simulated state
    switch (action) {
      case 'light_on':
        _simulatedData = _simulatedData.copyWith(lightState: true);
        break;
      case 'light_off':
        _simulatedData = _simulatedData.copyWith(lightState: false);
        break;
      case 'heater_on':
        _simulatedData = _simulatedData.copyWith(heaterState: true);
        break;
      case 'heater_off':
        _simulatedData = _simulatedData.copyWith(heaterState: false);
        break;
      case 'fan_on':
        _simulatedData = _simulatedData.copyWith(fanState: true);
        break;
      case 'fan_off':
        _simulatedData = _simulatedData.copyWith(fanState: false);
        break;
      case 'tare':
        _simulatedData = _simulatedData.copyWith(loadCellRaw: 0.0);
        break;
    }

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/camera/control"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"action": action}),
          )
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {
      // Offline fallback: simulated local action succeeded
      return true;
    }
  }
}
