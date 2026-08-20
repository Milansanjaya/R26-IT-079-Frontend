/// Models for the Drying (Time & Spoilage) prediction module.
///
/// These map the responses of the TimeAndSpoilagePredictionService
/// `/api/drying/*` integration routes onto typed Dart objects.
library;

/// One contributing factor behind a prediction — an IoT reading or derived
/// metric with its current value, expected/normal range, and effect. Powers
/// the "why" detail screens.
class PredictionFactor {
  final String key;
  final String label;
  final double value;
  final String unit;
  final String normalRange;
  final String status; // good | elevated | high | low
  final String effect;

  PredictionFactor({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.normalRange,
    required this.status,
    required this.effect,
  });

  factory PredictionFactor.fromJson(Map<String, dynamic> json) {
    return PredictionFactor(
      key: json["key"]?.toString() ?? "",
      label: json["label"]?.toString() ?? "",
      value: _toDouble(json["value"]),
      unit: json["unit"]?.toString() ?? "",
      normalRange: json["normal_range"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "good",
      effect: json["effect"]?.toString() ?? "",
    );
  }
}

List<PredictionFactor> _factorsFrom(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(PredictionFactor.fromJson)
      .toList();
}

/// The single active batch currently in the drying oven.
class ActiveDryingBatch {
  final String batchId;
  final String fishType;
  final double initialWeightKg;
  final String? dryingStartedAt;
  final double elapsedDryingHours;

  ActiveDryingBatch({
    required this.batchId,
    required this.fishType,
    required this.initialWeightKg,
    required this.dryingStartedAt,
    required this.elapsedDryingHours,
  });

  factory ActiveDryingBatch.fromJson(Map<String, dynamic> json) {
    return ActiveDryingBatch(
      batchId: json["batchId"]?.toString() ?? "",
      fishType: json["fishType"]?.toString() ?? "",
      initialWeightKg: _toDouble(json["initialWeightKg"]),
      dryingStartedAt: json["dryingStartedAt"]?.toString(),
      elapsedDryingHours: _toDouble(json["elapsedDryingHours"]),
    );
  }
}

/// Result of the drying-time prediction for the active batch.
class DryingTimeResult {
  final String batchId;
  final double predictedRemainingHours;
  final String modelUsed;
  final String? createdAt;
  final List<PredictionFactor> factors;

  DryingTimeResult({
    required this.batchId,
    required this.predictedRemainingHours,
    required this.modelUsed,
    required this.createdAt,
    this.factors = const [],
  });

  factory DryingTimeResult.fromJson(Map<String, dynamic> json) {
    return DryingTimeResult(
      batchId: json["batch_id"]?.toString() ?? "",
      predictedRemainingHours:
          _toDouble(json["predicted_remaining_drying_time_hours"]),
      modelUsed: json["model_used"]?.toString() ?? "-",
      createdAt: json["created_at"]?.toString(),
      factors: _factorsFrom(json["factors"]),
    );
  }
}

/// Result of the spoilage-risk classification for the active batch.
class SpoilageRiskResult {
  final String batchId;
  final String smellLevel;
  final String spoilageRisk; // High | Medium | Low
  final String modelUsed;
  final String? createdAt;
  final List<PredictionFactor> factors;

  SpoilageRiskResult({
    required this.batchId,
    required this.smellLevel,
    required this.spoilageRisk,
    required this.modelUsed,
    required this.createdAt,
    this.factors = const [],
  });

  factory SpoilageRiskResult.fromJson(Map<String, dynamic> json) {
    return SpoilageRiskResult(
      batchId: json["batch_id"]?.toString() ?? "",
      smellLevel: json["smell_level"]?.toString() ?? "-",
      spoilageRisk: json["spoilage_risk"]?.toString() ?? "-",
      modelUsed: json["model_used"]?.toString() ?? "-",
      createdAt: json["created_at"]?.toString(),
      factors: _factorsFrom(json["factors"]),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}
