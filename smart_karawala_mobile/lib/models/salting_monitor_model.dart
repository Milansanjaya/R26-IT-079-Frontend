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

  factory SaltingMonitorModel.fromJson(
      Map<String, dynamic> json) {
    return SaltingMonitorModel(
      batchId: json["batchId"],
      fishType: json["fishType"],

      status: json["status"],

      startTime: json["startTime"],

      progress:
          (json["progress"] as num).toDouble(),

      currentWeight:
          (json["currentWeight"] as num).toDouble(),

      weightLoss:
          (json["weightLoss"] as num).toDouble(),

      weightLossPercentage:
          (json["weightLossPercentage"] as num)
              .toDouble(),

      remainingHours:
          (json["remainingHours"] as num)
              .toDouble(),
    );
  }
}