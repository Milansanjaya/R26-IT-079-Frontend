import '../services/Salt/salt_service.dart';

class SaltingMonitorModel {
  final String batchId;
  final String fishType;
  final String status;
  final String startTime;

  final double progress;
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
    required this.currentWeight,
    required this.weightLoss,
    required this.weightLossPercentage,
    required this.remainingHours,
  });

  factory SaltingMonitorModel.fromJson(Map<String, dynamic> json) {
    final cleanedWeight = (json["cleanedWeight"] as num?)?.toDouble() ?? 85.0;
    final totalHours = SaltService.calculateRecommendedDuration(cleanedWeight).toDouble();

    double remaining = (json["remainingHours"] as num?)?.toDouble() ?? totalHours;
    if (remaining > totalHours) {
      remaining = totalHours;
    }

    return SaltingMonitorModel(
      batchId: json["batchId"] ?? "",
      fishType: json["fishType"] ?? "",
      status: json["status"] ?? "In Progress",
      startTime: json["startTime"] ?? "",
      progress: (json["progress"] as num?)?.toDouble() ?? 0.0,
      currentWeight: (json["currentWeight"] as num?)?.toDouble() ?? cleanedWeight,
      weightLoss: (json["weightLoss"] as num?)?.toDouble() ?? 0.0,
      weightLossPercentage: (json["weightLossPercentage"] as num?)?.toDouble() ?? 0.0,
      remainingHours: remaining,
    );
  }
}