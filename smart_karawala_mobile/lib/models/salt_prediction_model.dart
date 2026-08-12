import '../services/Salt/salt_service.dart';

class SaltPredictionModel {
  final String batchId;
  final String fishType;
  final double cleanedWeight;
  final double saltAmount;
  final int saltingDurationHours;

  SaltPredictionModel({
    required this.batchId,
    required this.fishType,
    required this.cleanedWeight,
    required this.saltAmount,
    required this.saltingDurationHours,
  });

  factory SaltPredictionModel.fromJson(Map<String, dynamic> json) {
    final weight = (json["cleanedWeight"] as num?)?.toDouble() ?? 0.0;
    int duration = (json["saltingDurationHours"] as num?)?.toInt() ?? 0;

    if (duration == 0 && weight > 0) {
      duration = SaltService.calculateRecommendedDuration(weight);
    }

    return SaltPredictionModel(
      batchId: json["batchId"] ?? "",
      fishType: json["fishType"] ?? "",
      cleanedWeight: weight,
      saltAmount: (json["saltAmount"] as num?)?.toDouble() ?? 0.0,
      saltingDurationHours: duration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "batchId": batchId,
      "fishType": fishType,
      "cleanedWeight": cleanedWeight,
      "saltAmount": saltAmount,
      "saltingDurationHours": saltingDurationHours,
    };
  }
}