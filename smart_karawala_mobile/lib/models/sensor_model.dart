class SensorModel {
  final double temperature;
  final double humidity;
  final double dsTemperature;
  final int gas;
  final int rawWeight;
  final double weight;
  final bool heater;
  final bool light;
  final bool fan;

  SensorModel({
    required this.temperature,
    required this.humidity,
    required this.dsTemperature,
    required this.gas,
    required this.rawWeight,
    required this.weight,
    required this.heater,
    required this.light,
    required this.fan,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      temperature: (json["temperature"] ?? 0).toDouble(),
      humidity: (json["humidity"] ?? 0).toDouble(),
      dsTemperature: (json["ds_temperature"] ?? 0).toDouble(),
      gas: json["gas"] ?? 0,
      rawWeight: json["raw_weight"] ?? 0,
      weight: (json["weight"] ?? 0).toDouble(),
      heater: json["heater"] ?? false,
      light: json["light"] ?? false,
      fan: json["fan"] ?? false,
    );
  }
}