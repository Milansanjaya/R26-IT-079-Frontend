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
  }) : timestamp = timestamp ?? DateTime.now();

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    final tempC = _toDouble(json['temperature_c'] ?? json['temp_c'] ?? 32.5);
    final tempF = json['temperature_f'] != null
        ? _toDouble(json['temperature_f'])
        : (tempC * 9 / 5) + 32;

    return TelemetryData(
      temperatureC: tempC,
      temperatureF: tempF,
      humidityPercent: _toDouble(json['humidity_percent'] ?? json['humidity'] ?? 52.0),
      gasRaw: _toDouble(json['gas_raw'] ?? json['gas'] ?? 245.0),
      loadCellRaw: _toDouble(json['load_cell_raw'] ?? json['load_cell'] ?? 1180.0),
      heaterState: json['heater_state'] ?? json['heater'] ?? false,
      lightState: json['light_state'] ?? json['light'] ?? false,
      fanState: json['fan_state'] ?? json['fan'] ?? false,
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
    );
  }
}
