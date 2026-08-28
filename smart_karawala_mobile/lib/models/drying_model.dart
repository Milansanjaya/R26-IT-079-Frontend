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

  /// Recommended temperature and total drying time from the pre-drying
  /// prediction (POST /api/predict/initial), if that step was run before
  /// starting. Null if drying was started without a prior prediction.
  final double? initialTemperatureC;
  final double? initialTotalHours;

  /// Ground truth from the IoT oven. The active-batch record is only
  /// bookkeeping; these say whether the heater is ACTUALLY running, so the
  /// countdown can be paused when the oven stops or faults.
  final bool ovenRunning;
  final String? ovenStatus;
  final bool ovenReachable;
  final String? ovenStoppedReason;

  /// Id the oven session runs under. Usually equals [batchId], but differs
  /// when the batch's own oven session was terminal and a fresh id was used.
  final String? ovenSessionId;

  ActiveDryingBatch({
    required this.batchId,
    required this.fishType,
    required this.initialWeightKg,
    required this.dryingStartedAt,
    required this.elapsedDryingHours,
    this.initialTemperatureC,
    this.initialTotalHours,
    this.ovenRunning = true,
    this.ovenStatus,
    this.ovenReachable = true,
    this.ovenStoppedReason,
    this.ovenSessionId,
  });

  factory ActiveDryingBatch.fromJson(Map<String, dynamic> json) {
    return ActiveDryingBatch(
      batchId: json["batchId"]?.toString() ?? "",
      fishType: json["fishType"]?.toString() ?? "",
      initialWeightKg: _toDouble(json["initialWeightKg"]),
      dryingStartedAt: json["dryingStartedAt"]?.toString(),
      elapsedDryingHours: _toDouble(json["elapsedDryingHours"]),
      initialTemperatureC: json["initialTemperatureC"] == null
          ? null
          : _toDouble(json["initialTemperatureC"]),
      initialTotalHours: json["initialTotalHours"] == null
          ? null
          : _toDouble(json["initialTotalHours"]),
      // Default to "running" when the field is absent so an older backend
      // doesn't make the UI look permanently stopped.
      ovenRunning: json["ovenRunning"] as bool? ?? true,
      ovenStatus: json["ovenStatus"]?.toString(),
      ovenReachable: json["ovenReachable"] as bool? ?? true,
      ovenStoppedReason: json["ovenStoppedReason"]?.toString(),
      ovenSessionId: json["ovenSessionId"]?.toString(),
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

/// Result of the over-drying / burn-risk check for the active batch.
///
/// Matches GET /api/drying/active/overdrying-risk. This is a separate risk
/// axis from spoilage: spoilage means "too wet for too long", over-drying
/// means "already dry and still being heated" - the two call for opposite
/// action, so they are never merged into one field.
class OverDryingRiskResult {
  final String batchId;
  final String overDryingRisk; // High | Medium | Low
  final List<String> reasons;
  final bool ovenStopped;
  final String? stopReason;
  final String? stopError;
  final String? explanation; // plain-language LLM note, only set at High risk
  final String? createdAt;

  OverDryingRiskResult({
    required this.batchId,
    required this.overDryingRisk,
    required this.reasons,
    required this.ovenStopped,
    required this.stopReason,
    required this.stopError,
    required this.explanation,
    required this.createdAt,
  });

  factory OverDryingRiskResult.fromJson(Map<String, dynamic> json) {
    return OverDryingRiskResult(
      batchId: json["batch_id"]?.toString() ?? "",
      overDryingRisk: json["over_drying_risk"]?.toString() ?? "Low",
      reasons: (json["reasons"] as List?)?.map((e) => e.toString()).toList() ?? [],
      ovenStopped: json["oven_stopped"] == true,
      stopReason: json["stop_reason"]?.toString(),
      stopError: json["stop_error"]?.toString(),
      explanation: json["explanation"]?.toString(),
      createdAt: json["created_at"]?.toString(),
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}
