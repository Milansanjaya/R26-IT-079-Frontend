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

    final status = (json["status"] as String?) ?? "In Progress";
    final progress = (json["progress"] as num?)?.toDouble() ?? 0.0;

    double saltAmount = (json["saltAmount"] as num?)?.toDouble() ?? 0.0;
    if (saltAmount <= 0 && cleanedWeight > 0) {
      final ratio = SaltService.getSaltRatio(fishType);
      saltAmount = cleanedWeight * ratio;
    }

    final addedSaltWeight = 0.75 * saltAmount;
    final isCompleted = status.toLowerCase() == 'completed' || progress >= 100;
    final completionRatio = isCompleted ? 1.0 : (progress / 100.0).clamp(0.0, 1.0);

    final weightLoss = (json["weightLoss"] as num?)?.toDouble() ?? 0.0;
    final rawCurrentWeight = (json["currentWeight"] as num?)?.toDouble();

    double currentWeight;
    if (rawCurrentWeight != null && rawCurrentWeight > 0) {
      currentWeight = rawCurrentWeight;
    } else {
      currentWeight = cleanedWeight + (completionRatio * addedSaltWeight);
    }

    if (currentWeight <= 0) {
      currentWeight = cleanedWeight > 0 ? cleanedWeight : 0.1;
    }

    return SaltingMonitorModel(
      batchId: json["batchId"] ?? "",
      fishType: fishType,
      status: status,
      startTime: json["startTime"] ?? "",
      progress: progress,
      cleanedWeight: cleanedWeight,
      currentWeight: currentWeight,
      weightLoss: weightLoss,
      weightLossPercentage: (json["weightLossPercentage"] as num?)?.toDouble() ?? 0.0,
      remainingHours: remaining,
    );
  }
}