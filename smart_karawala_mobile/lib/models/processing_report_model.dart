class ProcessingReportModel {
  final String batchId;
  final String fishType;
  final String date;
  final double rawWeight;
  final double predictedWaste;
  final double wastePercentage;
  final String status;
  final String? location;
  final String? notes;

  ProcessingReportModel({
    required this.batchId,
    required this.fishType,
    required this.date,
    required this.rawWeight,
    required this.predictedWaste,
    required this.wastePercentage,
    required this.status,
    this.location,
    this.notes,
  });

  factory ProcessingReportModel.fromJson(Map<String, dynamic> json) {
    return ProcessingReportModel(
      batchId: json["batchId"] ?? "",
      fishType: json["fishType"] ?? "",
      date: json["date"] ?? "",
      rawWeight: (json["rawWeight"] ?? 0).toDouble(),
      predictedWaste: (json["predictedWaste"] ?? 0).toDouble(),
      wastePercentage: (json["wastePercentage"] ?? 0).toDouble(),
      status: json["status"] ?? "",
      location: json["location"],
      notes: json["notes"],
    );
  }
}