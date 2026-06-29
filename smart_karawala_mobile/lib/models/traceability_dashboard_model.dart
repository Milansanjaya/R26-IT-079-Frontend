class TraceabilityDashboardModel {
  final int totalBatches;
  final double totalWasteKg;
  final double averageWastePercentage;
  final int completedBatches;
  final int inProgressBatches;
  final int records;
  final List<RecentRecord> recentBatches;

  TraceabilityDashboardModel({
    required this.totalBatches,
    required this.totalWasteKg,
    required this.averageWastePercentage,
    required this.completedBatches,
    required this.inProgressBatches,
    required this.records,
    required this.recentBatches,
  });

  factory TraceabilityDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TraceabilityDashboardModel(
      totalBatches: json["totalBatches"] ?? 0,
      totalWasteKg: (json["totalWasteKg"] ?? 0).toDouble(),
      averageWastePercentage:
          (json["averageWastePercentage"] ?? 0).toDouble(),
      completedBatches: json["completedBatches"] ?? 0,
      inProgressBatches: json["inProgressBatches"] ?? 0,
      records: json["records"] ?? 0,
      recentBatches: (json["recentBatches"] as List? ?? [])
          .map((e) => RecentRecord.fromJson(e))
          .toList(),
    );
  }
}

class RecentRecord {
  final String batchId;
  final String fishType;
  final String date;
  final double predictedWaste;
  final double rawWeight;
  final String status;
  final String location;

  RecentRecord({
    required this.batchId,
    required this.fishType,
    required this.date,
    required this.predictedWaste,
    required this.rawWeight,
    required this.status,
    required this.location,
  });

  factory RecentRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecentRecord(
      batchId: json["batchId"] ?? "",
      fishType: json["fishType"] ?? "",
      date: json["date"] ?? "",
      predictedWaste: (json["predictedWaste"] ?? 0).toDouble(),
      rawWeight: (json["rawWeight"] ?? 0).toDouble(),
      status: json["status"] ?? "",
      location: json["location"] ?? "",
    );
  }

  double get wastePercentage {
    if (rawWeight == 0) return 0;
    return (predictedWaste / rawWeight) * 100;
  }
}