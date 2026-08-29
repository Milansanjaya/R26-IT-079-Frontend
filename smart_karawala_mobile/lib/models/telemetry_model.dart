class TelemetryData {
  final double temperatureC;
  final double temperatureF;
  final double humidityPercent;
  final double gasRaw;
  final double loadCellRaw;
  final bool heaterState;
  final bool lightState;
  final bool fanState;
  final DateTime timestamp;

  // Time-series history buffers for charts
  final List<double> tempHistory;
  final List<double> humidityHistory;
  final List<double> gasHistory;
  final List<double> weightHistory;

  TelemetryData({
    required this.temperatureC,
    required this.temperatureF,
    required this.humidityPercent,
    required this.gasRaw,
    required this.loadCellRaw,
    required this.heaterState,
    required this.lightState,
    required this.fanState,
    DateTime? timestamp,
    List<double>? tempHistory,
    List<double>? humidityHistory,
    List<double>? gasHistory,
    List<double>? weightHistory,
  })  : timestamp = timestamp ?? DateTime.now(),
        tempHistory = tempHistory ?? [],
        humidityHistory = humidityHistory ?? [],
        gasHistory = gasHistory ?? [],
        weightHistory = weightHistory ?? [];

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    final tempC = _toDouble(json['temperature_c'] ?? json['temp_c'] ?? json['sht_temp'] ?? 0.0);
    final tempF = json['temperature_f'] != null
        ? _toDouble(json['temperature_f'])
        : (tempC * 9 / 5) + 32;

    return TelemetryData(
      temperatureC: tempC,
      temperatureF: tempF,
      humidityPercent: _toDouble(json['humidity_percent'] ?? json['humidity'] ?? 0.0),
      gasRaw: _toDouble(json['gas_raw'] ?? json['gas'] ?? json['gas_value'] ?? 0.0),
      loadCellRaw: _toDouble(json['load_cell_raw'] ?? json['load_cell'] ?? json['weight_raw'] ?? 0.0),
      heaterState: json['heater_state'] ?? json['heaterState'] ?? json['heater'] ?? false,
      lightState: json['light_state'] ?? json['lightState'] ?? json['light'] ?? false,
      fanState: json['fan_state'] ?? json['fanState'] ?? json['fan'] ?? false,
    );
  }

  static double _toDouble(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  TelemetryData copyWith({
    double? temperatureC,
    double? temperatureF,
    double? humidityPercent,
    double? gasRaw,
    double? loadCellRaw,
    bool? heaterState,
    bool? lightState,
    bool? fanState,
    List<double>? tempHistory,
    List<double>? humidityHistory,
    List<double>? gasHistory,
    List<double>? weightHistory,
  }) {
    return TelemetryData(
      temperatureC: temperatureC ?? this.temperatureC,
      temperatureF: temperatureF ?? this.temperatureF,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      gasRaw: gasRaw ?? this.gasRaw,
      loadCellRaw: loadCellRaw ?? this.loadCellRaw,
      heaterState: heaterState ?? this.heaterState,
      lightState: lightState ?? this.lightState,
      fanState: fanState ?? this.fanState,
      tempHistory: tempHistory ?? this.tempHistory,
      humidityHistory: humidityHistory ?? this.humidityHistory,
      gasHistory: gasHistory ?? this.gasHistory,
      weightHistory: weightHistory ?? this.weightHistory,
    );
  }
}

class PredictionData {
  final double predictedTempC;
  final double predictedHumidityPercent;
  final double estimatedDurationHours;
  final double spoilageRisk;
  final String fishType;

  PredictionData({
    required this.predictedTempC,
    required this.predictedHumidityPercent,
    required this.estimatedDurationHours,
    required this.spoilageRisk,
    required this.fishType,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      predictedTempC: TelemetryData._toDouble(json['predicted_temp_c'] ?? json['recommended_temp'] ?? 36.0),
      predictedHumidityPercent: TelemetryData._toDouble(json['predicted_humidity'] ?? json['target_humidity'] ?? 45.0),
      estimatedDurationHours: TelemetryData._toDouble(json['estimated_duration_hours'] ?? json['estimated_hours'] ?? 4.5),
      spoilageRisk: TelemetryData._toDouble(json['spoilage_risk'] ?? 0.05),
      fishType: json['fish_type']?.toString() ?? "Katta",
    );
  }
}
