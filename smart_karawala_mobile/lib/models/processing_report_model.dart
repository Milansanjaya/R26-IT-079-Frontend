class ProcessingReportModel {
  final String batchId;
  final String fishType;
  final String date;
  final double rawWeight;
  final double predictedWaste;
  final double wastePercentage;
  final String status;

  ProcessingReportModel({
    required this.batchId,
    required this.fishType,
    required this.date,
    required this.rawWeight,
    required this.predictedWaste,
    required this.wastePercentage,
    required this.status,
  });

  factory ProcessingReportModel.fromJson(Map<String, dynamic> json) {
    return ProcessingReportModel(
      batchId: json["batchId"],
      fishType: json["fishType"],
      date: json["date"],
      rawWeight: (json["rawWeight"] as num).toDouble(),
      predictedWaste: (json["predictedWaste"] as num).toDouble(),
      wastePercentage: (json["wastePercentage"] as num).toDouble(),
      status: json["status"] ?? "",
    );
  }
}