import 'package:flutter/material.dart';
import '../../models/processing_report_model.dart';
import '../../services/Batch/pdf_service.dart';

class BatchDetailsScreen extends StatelessWidget {
  final ProcessingReportModel batch;

  const BatchDetailsScreen({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              //--------------------------------------------------
              // Header
              //--------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xff214E77),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: const [
                      Text(
                        "Smart",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("කරවල"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //--------------------------------------------------
              // Batch Summary Card
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),

                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 55,
                      height: 55,

                      decoration: BoxDecoration(
                        color: const Color(0xffEEF5FF),
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.assignment,
                        color: Color(0xff214E77),
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Batch ID",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            batch.batchId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xff103F73),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            batch.fishType,
                            style: const TextStyle(color: Colors.black54),
                          ),

                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),

                            decoration: BoxDecoration(
                              color:
                                  batch.status.toLowerCase().contains(
                                    "completed",
                                  )
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              batch.status,

                              style: TextStyle(
                                color:
                                    batch.status.toLowerCase().contains(
                                      "completed",
                                    )
                                    ? Colors.green
                                    : Colors.orange,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xff214E77),
                            ),

                            const SizedBox(width: 6),

                            Text(batch.date),
                          ],
                        ),

                        const SizedBox(height: 10),

                        const Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: Color(0xff214E77),
                            ),

                            SizedBox(width: 6),

                            Text("11:05 AM"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //--------------------------------------------------
              // 1. Basic Information
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "1. Basic Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff214E77),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            Icons.scale,
                            "Raw Weight",
                            "${batch.rawWeight.toStringAsFixed(1)} kg",
                          ),
                        ),

                        Expanded(
                          child: infoTile(
                            Icons.location_on,
                            "Location",
                            "Negombo",
                          ),
                        ),

                        Expanded(child: infoTile(Icons.note, "Notes", "-")),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            Icons.calendar_today,
                            "Date",
                            batch.date,
                          ),
                        ),

                        Expanded(
                          child: infoTile(
                            Icons.access_time,
                            "Time",
                            "11:05 AM",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              //--------------------------------------------------
              // 2. Prediction Summary
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "2. Prediction Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff214E77),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: predictionTile(
                            Icons.delete,
                            "Predicted Waste",
                            "${batch.predictedWaste.toStringAsFixed(1)} kg",
                            "${batch.wastePercentage.toStringAsFixed(1)}%",
                          ),
                        ),

                        Expanded(
                          child: predictionTile(
                            Icons.set_meal,
                            "Cleaned Weight",
                            "${(batch.rawWeight - batch.predictedWaste).toStringAsFixed(1)} kg",
                            "${(100 - batch.wastePercentage).toStringAsFixed(1)}%",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              //--------------------------------------------------
              // 3. Salt Information
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "3. Salt Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff214E77),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            Icons.inventory_2,
                            "Salt Amount",
                            "7.2 kg",
                          ),
                        ),

                        Expanded(
                          child: infoTile(
                            Icons.hourglass_bottom,
                            "Salting Duration",
                            "12 Hours",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              //--------------------------------------------------
              // 4. Monitoring Summary
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "4. Monitoring Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff214E77),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: monitoringTile(
                            Icons.scale,
                            "Initial",
                            "${batch.rawWeight.toStringAsFixed(1)} kg",
                          ),
                        ),

                        Expanded(
                          child: monitoringTile(
                            Icons.monitor_weight,
                            "Current",
                            "${(batch.rawWeight - batch.predictedWaste).toStringAsFixed(1)} kg",
                          ),
                        ),

                        Expanded(
                          child: monitoringTile(
                            Icons.trending_down,
                            "Weight Loss",
                            "${batch.predictedWaste.toStringAsFixed(1)} kg",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: monitoringTile(
                            Icons.percent,
                            "Loss %",
                            "${batch.wastePercentage.toStringAsFixed(1)}%",
                          ),
                        ),

                        Expanded(
                          child: monitoringTile(
                            Icons.verified_user,
                            "Status",
                            batch.status,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              //--------------------------------------------------
              // 5. Notification Information
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "5. Notification Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff214E77),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            Icons.notifications_active,
                            "Waste Notification",
                            "Sent",
                          ),
                        ),

                        Expanded(
                          child: infoTile(
                            Icons.people,
                            "Recipient",
                            "Fish Meal Company",
                          ),
                        ),

                        Expanded(
                          child: infoTile(Icons.sms, "Channel", "In-App, SMS"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              //--------------------------------------------------
              // Buttons
              //--------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back to Dashboard"),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        backgroundColor: const Color(0xff214E77),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await PdfService.generateReport(
                          batchId: batch.batchId,
                          fishType: batch.fishType,
                          date: batch.date,
                          rawWeight: batch.rawWeight,
                          waste: batch.predictedWaste,
                          status: batch.status,
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Export Report"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Helper Widgets
  //--------------------------------------------------

  static Widget infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xff214E77), size: 22),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget predictionTile(
    IconData icon,
    String title,
    String value,
    String percent,
  ) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xff214E77)),

        const SizedBox(height: 8),

        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff103F73),
            fontSize: 16,
          ),
        ),

        Text(
          percent,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Widget monitoringTile(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xff214E77)),

        const SizedBox(height: 6),

        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),

        const SizedBox(height: 4),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff103F73),
          ),
        ),
      ],
    );
  }
}
