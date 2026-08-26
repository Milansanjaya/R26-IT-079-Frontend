import '../services/Salt/salt_service.dart';

class SaltingMonitorModel {
  final String batchId;
  final String fishType;
  final String status;
  final String startTime;

  final double progress;
  final double cleanedWeight;
  final double currentWeight;
  final double weightLoss;
  final double weightLossPercentage;
  final double remainingHours;

  SaltingMonitorModel({
    required this.batchId,
    required this.fishType,
    required this.status,
    required this.startTime,
    required this.progress,
    required this.cleanedWeight,
    required this.currentWeight,
    required this.weightLoss,
    required this.weightLossPercentage,
    required this.remainingHours,
  });

  factory SaltingMonitorModel.fromJson(Map<String, dynamic> json) {
    final fishType = json["fishType"] ?? "";
    final rawWeight = (json["rawWeight"] as num?)?.toDouble() ?? (json["raw_weight"] as num?)?.toDouble() ?? 0.0;
    final predictedWaste = (json["predictedWaste"] as num?)?.toDouble() ?? 0.0;

    double cleanedWeight = (json["cleanedWeight"] as num?)?.toDouble() ?? 0.0;
    if (cleanedWeight <= 0) {
      cleanedWeight = (rawWeight > 0 && predictedWaste > 0)
          ? (rawWeight - predictedWaste)
          : (rawWeight > 0 ? rawWeight : 0.1);
    }

    final totalHours = (json["saltingDurationHours"] as num?)?.toDouble() ??
        (json["recommendedDuration"] as num?)?.toDouble() ??
        SaltService.calculateRecommendedDuration(cleanedWeight, fishType).toDouble();

    double remaining = (json["remainingHours"] as num?)?.toDouble() ?? totalHours;
    if (remaining > totalHours) {
      remaining = totalHours;
    }

    final weightLoss = (json["weightLoss"] as num?)?.toDouble() ?? 0.0;
    final rawCurrentWeight = (json["currentWeight"] as num?)?.toDouble();
    double currentWeight = (rawCurrentWeight != null && rawCurrentWeight > 0 && rawCurrentWeight <= cleanedWeight)
        ? rawCurrentWeight
        : (cleanedWeight - weightLoss);
    if (currentWeight <= 0) {
      currentWeight = cleanedWeight > 0 ? cleanedWeight : 0.1;
    }

    return SaltingMonitorModel(
      batchId: json["batchId"] ?? "",
      fishType: json["fishType"] ?? "",
      status: json["status"] ?? "In Progress",
      startTime: json["startTime"] ?? "",
      progress: (json["progress"] as num?)?.toDouble() ?? 0.0,
      cleanedWeight: cleanedWeight,
      currentWeight: currentWeight,
      weightLoss: weightLoss,
      weightLossPercentage: (json["weightLossPercentage"] as num?)?.toDouble() ?? 0.0,
      remainingHours: remaining,
    );
  }
}