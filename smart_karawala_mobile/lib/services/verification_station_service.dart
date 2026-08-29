import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/telemetry_model.dart';

class VerificationStationService {
  static String stationHost = "http://localhost:3000";
  static String predictApiUrl = "http://localhost:8003/api/predict";

  // Rolling history lists (max 25 entries, starting empty)
  static final List<double> _tempHistory = [];
  static final List<double> _humidityHistory = [];
  static final List<double> _gasHistory = [];
  static final List<double> _weightHistory = [];

  static TelemetryData _simulatedData = TelemetryData(
    temperatureC: 36.5,
    temperatureF: 97.7,
    humidityPercent: 59.1,
    gasRaw: 620.0,
    loadCellRaw: 71486.0,
    heaterState: false,
    lightState: true,
    fanState: true,
    tempHistory: List.from(_tempHistory),
    humidityHistory: List.from(_humidityHistory),
    gasHistory: List.from(_gasHistory),
    weightHistory: List.from(_weightHistory),
  );

  /// Get Camera Stream URL
  static String getStreamUrl({String? host}) {
    final baseUrl = host ?? stationHost;
    return "$baseUrl/api/camera/stream";
  }

  /// Get Camera Frame Snapshot URL
  static String getSnapshotUrl({String? host}) {
    final baseUrl = host ?? stationHost;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "$baseUrl/api/camera/snapshot?t=$timestamp";
  }

  /// Add reading to rolling history (max 25 entries)
  static void _appendToHistory(List<double> list, double value) {
    list.add(value);
    if (list.length > 25) {
      list.removeAt(0);
    }
  }

  /// Get Telemetry Data from Verification Station API
  static Future<TelemetryData> fetchTelemetry({String? host}) async {
    final baseUrl = host ?? stationHost;
    final List<String> targets = [
      "http://172.20.10.2:8081/api/telemetry",
      "$baseUrl/api/camera/telemetry?host=172.20.10.2",
      "$baseUrl/api/camera/telemetry",
    ];

    TelemetryData? newData;

    for (final targetUrl in targets) {
      try {
        final response = await http
            .get(Uri.parse(targetUrl))
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final Map<String, dynamic> rawMap;
          if (data.containsKey('data') && data['data'] != null) {
            rawMap = Map<String, dynamic>.from(data['data']);
          } else if (data.containsKey('telemetry') && data['telemetry'] != null) {
            rawMap = Map<String, dynamic>.from(data['telemetry']);
          } else {
            rawMap = data;
          }
          newData = TelemetryData.fromJson(rawMap);
          break;
        }
      } catch (_) {
        // Try next candidate target
      }
    }

    newData ??= _getSimulatedTelemetry();

    _appendToHistory(_tempHistory, newData.temperatureC);
    _appendToHistory(_humidityHistory, newData.humidityPercent);
    _appendToHistory(_gasHistory, newData.gasRaw);
    _appendToHistory(_weightHistory, newData.loadCellRaw);

    return newData.copyWith(
      tempHistory: List.from(_tempHistory),
      humidityHistory: List.from(_humidityHistory),
      gasHistory: List.from(_gasHistory),
      weightHistory: List.from(_weightHistory),
    );
  }

  static TelemetryData _getSimulatedTelemetry() {
    final random = Random();
    final tempDelta = (random.nextDouble() - 0.48) * 0.3;
    final humidityDelta = (random.nextDouble() - 0.52) * 0.4;
    final gasDelta = (random.nextDouble() - 0.45) * 3;
    final weightDelta = -(random.nextDouble() * 2.0);

    final newTemp = double.parse((_simulatedData.temperatureC + tempDelta).clamp(28.0, 48.0).toStringAsFixed(1));
    final newHumidity = double.parse((_simulatedData.humidityPercent + humidityDelta).clamp(25.0, 85.0).toStringAsFixed(1));
    final newGas = double.parse((_simulatedData.gasRaw + gasDelta).clamp(100.0, 1000.0).toStringAsFixed(0));
    final newWeight = double.parse((_simulatedData.loadCellRaw + weightDelta).clamp(0.0, 200000.0).toStringAsFixed(0));

    _simulatedData = _simulatedData.copyWith(
      temperatureC: newTemp,
      humidityPercent: newHumidity,
      gasRaw: newGas,
      loadCellRaw: newWeight,
    );

    return _simulatedData;
  }

  /// Fetch AI Predicted Parameters (Target Temp, Target Humidity, Duration, Spoilage Risk)
  static Future<PredictionData> fetchPredictions() async {
    try {
      final response = await http
          .get(Uri.parse("$predictApiUrl/active"))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PredictionData.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Offline fallback
    }

    return PredictionData(
      predictedTempC: 36.0,
      predictedHumidityPercent: 42.0,
      estimatedDurationHours: 4.5,
      spoilageRisk: 0.04,
      fishType: "Katta / Sailfish",
    );
  }

  /// Send Actuator Control Action
  static Future<bool> sendControlAction(String action, {String? host}) async {
    final baseUrl = host ?? stationHost;

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
        _weightHistory.clear();
        _weightHistory.add(0.0);
        break;
    }

    final List<String> controlTargets = [
      "http://172.20.10.2:8081/api/control?action=$action",
      "$baseUrl/api/camera/control?action=$action",
    ];

    for (final targetUrl in controlTargets) {
      try {
        final getRes = await http.get(Uri.parse(targetUrl)).timeout(const Duration(seconds: 2));
        if (getRes.statusCode == 200) {
          return true;
        }
      } catch (_) {
        // Try next candidate
      }
    }
    return true;
  }
}
