class DryingSessionModel {
  final String batchId;
  final String mode;
  final String status;
  final double targetTemperature;
  final double targetHumidity;
  final String profileVersion;
  final String profileSource;
  final int? predictedDurationMinutes;
  final int coolingDurationSeconds;
  final double? initialWeight;
  final double? completionWeight;
  final double? currentWeight;
  final double? currentTemperature;
  final DateTime? startedAt;
  final DateTime? durationEndsAt;
  final DateTime? coolingEndsAt;
  final DateTime? completedAt;
  final DateTime? stoppedAt;
  final DateTime? lastSensorAt;
  final DateTime? updatedAt;
  final String? stopReason;
  final String? faultReason;
  final bool heaterCommanded;
  final bool fanCommanded;
  final bool lightCommanded;

  const DryingSessionModel({
    required this.batchId,
    required this.mode,
    required this.status,
    required this.targetTemperature,
    required this.targetHumidity,
    required this.profileVersion,
    required this.profileSource,
    required this.predictedDurationMinutes,
    required this.coolingDurationSeconds,
    required this.initialWeight,
    required this.completionWeight,
    required this.currentWeight,
    required this.currentTemperature,
    required this.startedAt,
    required this.durationEndsAt,
    required this.coolingEndsAt,
    required this.completedAt,
    required this.stoppedAt,
    required this.lastSensorAt,
    required this.updatedAt,
    required this.stopReason,
    required this.faultReason,
    required this.heaterCommanded,
    required this.fanCommanded,
    required this.lightCommanded,
  });

  factory DryingSessionModel.fromJson(Map<String, dynamic> json) {
    return DryingSessionModel(
      batchId: json['batch_id']?.toString() ?? '',
      mode: json['mode']?.toString().toUpperCase() ?? 'AUTO',
      status: json['status']?.toString().toUpperCase() ?? 'READY',
      targetTemperature: _toDouble(json['target_temperature_c']),
      targetHumidity: _toDouble(json['target_humidity_percent']),
      profileVersion: json['profile_version']?.toString() ?? 'unversioned',
      profileSource: json['profile_source']?.toString() ?? 'operator_override',
      predictedDurationMinutes: _toInt(json['predicted_duration_minutes']),
      coolingDurationSeconds: _toInt(json['cooling_duration_seconds']) ?? 0,
      initialWeight: _nullableDouble(json['initial_weight_kg']),
      completionWeight: _nullableDouble(json['completion_weight_kg']),
      currentWeight: _nullableDouble(json['current_weight_kg']),
      currentTemperature: _nullableDouble(json['current_temperature_c']),
      startedAt: _toDateTime(json['started_at']),
      durationEndsAt: _toDateTime(json['duration_ends_at']),
      coolingEndsAt: _toDateTime(json['cooling_ends_at']),
      completedAt: _toDateTime(json['completed_at']),
      stoppedAt: _toDateTime(json['stopped_at']),
      lastSensorAt: _toDateTime(json['last_sensor_at']),
      updatedAt: _toDateTime(json['updated_at']),
      stopReason: json['stop_reason']?.toString(),
      faultReason: json['fault_reason']?.toString(),
      heaterCommanded: json['heater_commanded'] == true,
      fanCommanded: json['fan_commanded'] == true,
      lightCommanded: json['light_commanded'] == true,
    );
  }

  bool get isRunning => status == 'DRYING' || status == 'COOLING';

  bool get isTerminal =>
      status == 'COMPLETED' || status == 'STOPPED' || status == 'FAULT';
}

class SensorModel {
  final String deviceId;
  final bool online;
  final DateTime? timestamp;
  final List<String> sensorErrors;
  final double temperature;
  final double humidity;
  final double? dsTemperature;
  final double? gas;
  final double? targetGas;
  final int? rawWeight;
  final double weight;
  final double initialWeight;
  final double targetWeight;
  final double progress;
  final double targetTemperature;
  final double targetHumidity;
  final bool heater;
  final bool light;
  final bool fan;
  final String? batchId;
  final String? dryingMode;
  final String? dryingStatus;
  final DryingSessionModel? session;

  const SensorModel({
    required this.deviceId,
    required this.online,
    this.timestamp,
    this.sensorErrors = const [],
    required this.temperature,
    required this.humidity,
    this.dsTemperature,
    this.gas,
    this.targetGas,
    this.rawWeight,
    required this.weight,
    required this.initialWeight,
    required this.targetWeight,
    required this.progress,
    required this.targetTemperature,
    required this.targetHumidity,
    required this.heater,
    required this.light,
    required this.fan,
    this.batchId,
    this.dryingMode,
    this.dryingStatus,
    this.session,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    final sessionJson = json['session'];
    final session = sessionJson is Map
        ? DryingSessionModel.fromJson(Map<String, dynamic>.from(sessionJson))
        : null;
    final rawErrors = json['sensor_errors'];

    return SensorModel(
      deviceId: json['device_id']?.toString() ?? 'ARDUINO-NANO',
      online: json['online'] == true,
      timestamp: _toDateTime(json['timestamp']),
      sensorErrors: rawErrors is List
          ? rawErrors.map((error) => error.toString()).toList(growable: false)
          : const [],
      temperature: _toDouble(json['temperature']),
      humidity: _toDouble(json['humidity']),
      dsTemperature: _nullableDouble(json['ds_temperature']),
      gas: _nullableDouble(json['gas']),
      targetGas: _nullableDouble(json['target_gas']),
      rawWeight: _toInt(json['raw_weight']),
      weight: _toDouble(json['weight']),
      initialWeight: _toDouble(
        json['initial_weight'] ?? session?.initialWeight,
      ),
      targetWeight: _toDouble(
        json['target_weight'] ?? session?.completionWeight,
      ),
      progress: _toDouble(json['progress']),
      targetTemperature: _toDouble(
        json['target_temperature'] ?? session?.targetTemperature,
      ),
      targetHumidity: _toDouble(
        json['target_humidity'] ?? session?.targetHumidity,
      ),
      heater: json['heater'] == true,
      light: json['light'] == true,
      fan: json['fan'] == true,
      batchId: session?.batchId,
      dryingMode: json['mode']?.toString().toUpperCase() ?? session?.mode,
      dryingStatus:
          json['drying_status']?.toString().toUpperCase() ?? session?.status,
      session: session,
    );
  }

  SensorModel copyWith({
    String? deviceId,
    bool? online,
    DateTime? timestamp,
    List<String>? sensorErrors,
    double? temperature,
    double? humidity,
    double? dsTemperature,
    double? gas,
    double? targetGas,
    int? rawWeight,
    double? weight,
    double? initialWeight,
    double? targetWeight,
    double? progress,
    double? targetTemperature,
    double? targetHumidity,
    bool? heater,
    bool? light,
    bool? fan,
    String? batchId,
    String? dryingMode,
    String? dryingStatus,
    DryingSessionModel? session,
  }) {
    return SensorModel(
      deviceId: deviceId ?? this.deviceId,
      online: online ?? this.online,
      timestamp: timestamp ?? this.timestamp,
      sensorErrors: sensorErrors ?? this.sensorErrors,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      dsTemperature: dsTemperature ?? this.dsTemperature,
      gas: gas ?? this.gas,
      targetGas: targetGas ?? this.targetGas,
      rawWeight: rawWeight ?? this.rawWeight,
      weight: weight ?? this.weight,
      initialWeight: initialWeight ?? this.initialWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      progress: progress ?? this.progress,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      targetHumidity: targetHumidity ?? this.targetHumidity,
      heater: heater ?? this.heater,
      light: light ?? this.light,
      fan: fan ?? this.fan,
      batchId: batchId ?? this.batchId,
      dryingMode: dryingMode ?? this.dryingMode,
      dryingStatus: dryingStatus ?? this.dryingStatus,
      session: session ?? this.session,
    );
  }
}

double _toDouble(dynamic value) => _nullableDouble(value) ?? 0.0;

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
