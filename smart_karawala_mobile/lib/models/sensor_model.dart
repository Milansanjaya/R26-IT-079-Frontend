class SensorModel {
  final String deviceId;
  final bool online;

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

  SensorModel({
    required this.deviceId,
    required this.online,

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
  });

  factory SensorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SensorModel(
      deviceId:
          json["device_id"]?.toString() ??
          "ARDUINO-NANO",

      online:
          json["online"] == true,

      temperature:
          _toDouble(json["temperature"]),

      humidity:
          _toDouble(json["humidity"]),

      dsTemperature:
          json["ds_temperature"] == null
              ? null
              : _toDouble(
                  json["ds_temperature"],
                ),

      gas:
          json["gas"] == null
              ? null
              : _toDouble(
                  json["gas"],
                ),

      // Gas target comes from your friend's backend
      targetGas:
          json["target_gas"] == null
              ? null
              : _toDouble(
                  json["target_gas"],
                ),

      rawWeight:
          json["raw_weight"] == null
              ? null
              : int.tryParse(
                  json["raw_weight"].toString(),
                ),

      weight:
          _toDouble(json["weight"]),

      // Initial fish weight
      initialWeight:
          _toDouble(
            json["initial_weight"],
          ),

      // Target/final fish weight
      targetWeight:
          _toDouble(
            json["target_weight"],
          ),

      // Drying progress calculated by backend
      progress:
          _toDouble(
            json["progress"],
          ),

      targetTemperature:
          _toDouble(
            json["target_temperature"],
          ),

      targetHumidity:
          _toDouble(
            json["target_humidity"],
          ),

      heater:
          json["heater"] == true,

      light:
          json["light"] == true,

      fan:
          json["fan"] == true,
    );
  }

  static double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0.0;
  }

  SensorModel copyWith({
    String? deviceId,
    bool? online,

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
  }) {
    return SensorModel(
      deviceId:
          deviceId ?? this.deviceId,

      online:
          online ?? this.online,

      temperature:
          temperature ?? this.temperature,

      humidity:
          humidity ?? this.humidity,

      dsTemperature:
          dsTemperature ??
          this.dsTemperature,

      gas:
          gas ?? this.gas,

      targetGas:
          targetGas ?? this.targetGas,

      rawWeight:
          rawWeight ?? this.rawWeight,

      weight:
          weight ?? this.weight,

      initialWeight:
          initialWeight ??
          this.initialWeight,

      targetWeight:
          targetWeight ??
          this.targetWeight,

      progress:
          progress ?? this.progress,

      targetTemperature:
          targetTemperature ??
          this.targetTemperature,

      targetHumidity:
          targetHumidity ??
          this.targetHumidity,

      heater:
          heater ?? this.heater,

      light:
          light ?? this.light,

      fan:
          fan ?? this.fan,
    );
  }
}