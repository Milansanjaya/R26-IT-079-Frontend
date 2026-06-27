class BatchModel {
  final String batchId;
  final String fishType;
  final double rawWeight;
  final double predictedWaste;
  final double cleanedWeight;
  final String location;
  final String date;
  final String? notes;

  BatchModel({
    required this.batchId,
    required this.fishType,
    required this.rawWeight,
    required this.predictedWaste,
    required this.cleanedWeight,
    required this.location,
    required this.date,
    this.notes,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      batchId: json["batchId"] ?? "",
      fishType: json["fishType"] ?? "",
      rawWeight: (json["rawWeight"] ?? 0).toDouble(),
      predictedWaste: (json["predictedWaste"] ?? 0).toDouble(),
      cleanedWeight: (json["cleanedWeight"] ?? 0).toDouble(),
      location: json["location"] ?? "",
      date: json["date"] ?? "",
      notes: json["notes"],
    );
  }
}