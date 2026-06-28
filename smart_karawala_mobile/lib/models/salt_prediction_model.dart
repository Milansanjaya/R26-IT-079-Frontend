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
    return SaltPredictionModel(
      batchId: json["batchId"] ?? "",
      fishType: json["fishType"] ?? "",
      cleanedWeight:
          (json["cleanedWeight"] as num?)?.toDouble() ?? 0.0,
      saltAmount:
          (json["saltAmount"] as num?)?.toDouble() ?? 0.0,
      saltingDurationHours:
          (json["saltingDurationHours"] as num?)?.toInt() ?? 0,
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