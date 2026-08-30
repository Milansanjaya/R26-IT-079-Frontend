class TelemetryData {
  final double temperatureC;
  final double temperatureF;
  final double humidityPercent;
  final double gasRaw;
  final double loadCellRaw; // Weight in grams / raw count
  final double weightKg; // Weight in kg
  final bool heaterState;
  final bool lightState;
  final bool fanState;
  final bool isConnected;
  final bool isBedEmpty;
  final int detectedFishCount;
  final int colorDiscolorationsCount;
  final int colorMatchPercent;
  final String dryingStage;
  final String liveQuality;
  final String drynessLevel;
  final String activeBatchId;
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
    this.weightKg = 0.0,
    required this.heaterState,
    required this.lightState,
    required this.fanState,
    this.isConnected = true,
    this.isBedEmpty = false,
    this.detectedFishCount = 2,
    this.colorDiscolorationsCount = 4,
    this.colorMatchPercent = 77,
    this.dryingStage = "PHASE 2 (CORE FLESH CURING)",
    this.liveQuality = "GRADE C (DEFECTIVE)",
    this.drynessLevel = "PROPER (~18% Moisture)",
    this.activeBatchId = "BATCH-20260830-01",
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

  /// Disconnected offline data state
  factory TelemetryData.offline() {
    return TelemetryData(
      temperatureC: 0.0,
      temperatureF: 0.0,
      humidityPercent: 0.0,
      gasRaw: 0.0,
      loadCellRaw: 0.0,
      weightKg: 0.0,
      heaterState: false,
      lightState: false,
      fanState: false,
      isConnected: false,
      isBedEmpty: true,
      detectedFishCount: 0,
      colorDiscolorationsCount: 0,
      colorMatchPercent: 0,
      dryingStage: "STANDBY",
      liveQuality: "OFFLINE",
      drynessLevel: "UNKNOWN",
      activeBatchId: "OFFLINE",
      tempHistory: [],
      humidityHistory: [],
      gasHistory: [],
      weightHistory: [],
    );
  }

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    // Map fields from SmartDryingEnvironmentMonitoring (port 8002) and Verification Station (port 3000)
    final tempC = toDouble(json['temperature'] ?? json['temperature_c'] ?? json['temp_c'] ?? json['sht_temp'] ?? 0.0);
    final tempF = json['temperature_f'] != null
        ? toDouble(json['temperature_f'])
        : (tempC * 9 / 5) + 32;

    final double rawVal = json['raw_weight'] != null
        ? toDouble(json['raw_weight'])
        : toDouble(json['load_cell_raw'] ?? json['load_cell'] ?? 0.0);

    double convertedKg = toDouble(json['weight'] ?? json['weight_kg'] ?? 0.0);
    double convertedGrams = convertedKg * 1000.0;

    // Convert raw HX711 ADC counts into converted grams if raw > 500 and weight is not provided
    if (convertedKg <= 0.0 && rawVal > 500) {
      convertedGrams = ((rawVal - 12000).abs() / 415.0).clamp(0.0, 5000.0);
      convertedKg = convertedGrams / 1000.0;
    }

    final isOnline = json['online'] ?? json['nano_connected'] ?? json['connected'] ?? true;

    final bool bedEmptyState;
    if (json['is_bed_empty'] != null) {
      bedEmptyState = json['is_bed_empty'] == true;
    } else {
      bedEmptyState = false;
    }

    final fishCount = json['detected_fish_count'] ?? (bedEmptyState ? 0 : 2);
    final discolorations = json['color_discolorations'] ?? json['discolorations_count'] ?? (bedEmptyState ? 0 : 4);
    final colorMatch = json['color_match_percent'] ?? (bedEmptyState ? 0 : 77);
    final stageStr = json['drying_stage']?.toString() ?? "PHASE 2 (CORE FLESH CURING)";
    final qualityStr = json['live_quality']?.toString() ?? "GRADE C (DEFECTIVE)";
    final drynessStr = json['dryness_level']?.toString() ?? "PROPER (~18% Moisture)";
    final batchIdStr = json['batch_id']?.toString() ?? json['session']?['batch_id']?.toString() ?? "BATCH-20260830-01";

    return TelemetryData(
      temperatureC: tempC,
      temperatureF: tempF,
      humidityPercent: toDouble(json['humidity'] ?? json['humidity_percent'] ?? 0.0),
      gasRaw: toDouble(json['gas'] ?? json['air_quality'] ?? json['gas_raw'] ?? json['gas_value'] ?? 0.0),
      loadCellRaw: convertedGrams,
      weightKg: convertedKg,
      heaterState: json['heater'] ?? json['heater_state'] ?? json['heaterState'] ?? false,
      lightState: json['light'] ?? json['light_state'] ?? json['lightState'] ?? false,
      fanState: json['fan'] ?? json['fan_state'] ?? json['fanState'] ?? false,
      isConnected: isOnline is bool ? isOnline : true,
      isBedEmpty: bedEmptyState,
      detectedFishCount: fishCount is int ? fishCount : 2,
      colorDiscolorationsCount: discolorations is int ? discolorations : 4,
      colorMatchPercent: colorMatch is int ? colorMatch : 77,
      dryingStage: stageStr,
      liveQuality: qualityStr,
      drynessLevel: drynessStr,
      activeBatchId: batchIdStr,
    );
  }

  static double toDouble(dynamic val) {
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
    double? weightKg,
    bool? heaterState,
    bool? lightState,
    bool? fanState,
    bool? isConnected,
    bool? isBedEmpty,
    int? detectedFishCount,
    int? colorDiscolorationsCount,
    int? colorMatchPercent,
    String? dryingStage,
    String? liveQuality,
    String? drynessLevel,
    String? activeBatchId,
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
      weightKg: weightKg ?? this.weightKg,
      heaterState: heaterState ?? this.heaterState,
      lightState: lightState ?? this.lightState,
      fanState: fanState ?? this.fanState,
      isConnected: isConnected ?? this.isConnected,
      isBedEmpty: isBedEmpty ?? this.isBedEmpty,
      detectedFishCount: detectedFishCount ?? this.detectedFishCount,
      colorDiscolorationsCount: colorDiscolorationsCount ?? this.colorDiscolorationsCount,
      colorMatchPercent: colorMatchPercent ?? this.colorMatchPercent,
      dryingStage: dryingStage ?? this.dryingStage,
      liveQuality: liveQuality ?? this.liveQuality,
      drynessLevel: drynessLevel ?? this.drynessLevel,
      activeBatchId: activeBatchId ?? this.activeBatchId,
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
    final tempVal = json['initialTemperatureC'] ??
        json['initial_temperature_c'] ??
        json['target_temperature'] ??
        json['target_temperature_c'] ??
        json['predicted_temp_c'] ??
        json['recommended_temp'] ??
        100.0;

    final hoursVal = json['initialTotalHours'] ??
        json['initial_total_hours'] ??
        json['estimated_duration_hours'] ??
        json['estimated_hours'] ??
        (json['predicted_duration_minutes'] != null
            ? (json['predicted_duration_minutes'] as num) / 60.0
            : null) ??
        2.0;

    final fishVal = json['fishType'] ?? json['fish_type'] ?? "Linna";

    return PredictionData(
      predictedTempC: TelemetryData.toDouble(tempVal),
      predictedHumidityPercent: TelemetryData.toDouble(
          json['predicted_humidity'] ?? json['target_humidity'] ?? 45.0),
      estimatedDurationHours: TelemetryData.toDouble(hoursVal),
      spoilageRisk: TelemetryData.toDouble(json['spoilage_risk'] ?? 0.04),
      fishType: fishVal.toString(),
    );
  }
}
