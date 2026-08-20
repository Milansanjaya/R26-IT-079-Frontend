import 'package:flutter/material.dart';
import '../../models/processing_report_model.dart';
import '../../services/Batch/pdf_service.dart';
import '../../widgets/Batch/colors.dart';
import '../../widgets/Batch/batch_stage_chip.dart';
import '../../widgets/Drying/drying_process_card.dart';
import '../../core/batch_stage.dart';
import '../../services/Drying/drying_service.dart';
import '../admin/admin_home_screen.dart';
import '../Drying/time_prediction_screen.dart';


class BatchDetailsScreen extends StatelessWidget {
  final ProcessingReportModel batch;

  const BatchDetailsScreen({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header navigation row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminHomeScreen(),
                        ),
                      );
                    },
                    child: Image.asset('assets/images/logo.png', height: 70),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                "Batch Details",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Batch Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Batch ID",
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            batch.batchId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            batch.fishType,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          BatchStageChip(
                            stage: BatchStage.fromStatusString(batch.status),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.hint,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              batch.date,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 14,
                              color: AppColors.hint,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "11:05 AM",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 1. Basic Information
              _buildSectionCard(
                title: "1. Basic Information",
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            Icons.scale_outlined,
                            "Raw Weight",
                            "${batch.rawWeight.toStringAsFixed(1)} kg",
                          ),
                        ),
                        Expanded(
                          child: infoTile(
                            Icons.location_on_outlined,
                            "Location",
                            "Negombo",
                          ),
                        ),
                        Expanded(
                          child: infoTile(
                            Icons.notes_rounded,
                            "Notes",
                            "-",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: infoTile(
                            Icons.calendar_today_outlined,
                            "Date",
                            batch.date,
                          ),
                        ),
                        Expanded(
                          child: infoTile(
                            Icons.access_time_outlined,
                            "Time",
                            "11:05 AM",
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Prediction Summary
              _buildSectionCard(
                title: "2. Prediction Summary",
                child: Row(
                  children: [
                    Expanded(
                      child: predictionTile(
                        Icons.delete_outline_rounded,
                        "Predicted Waste",
                        "${batch.predictedWaste.toStringAsFixed(1)} kg",
                        "${batch.wastePercentage.toStringAsFixed(1)}%",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: predictionTile(
                        Icons.set_meal_outlined,
                        "Cleaned Weight",
                        "${(batch.rawWeight - batch.predictedWaste).toStringAsFixed(1)} kg",
                        "${(100 - batch.wastePercentage).toStringAsFixed(1)}%",
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Salt Information
              _buildSectionCard(
                title: "3. Salt Information",
                child: Row(
                  children: [
                    Expanded(
                      child: infoTile(
                        Icons.opacity_outlined,
                        "Salt Amount",
                        "7.2 kg",
                      ),
                    ),
                    Expanded(
                      child: infoTile(
                        Icons.hourglass_empty_outlined,
                        "Salting Duration",
                        "12 Hours",
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Monitoring Summary
              _buildSectionCard(
                title: "4. Monitoring Summary",
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: monitoringTile(
                            Icons.scale_outlined,
                            "Initial Weight",
                            "${batch.rawWeight.toStringAsFixed(1)} kg",
                          ),
                        ),
                        Expanded(
                          child: monitoringTile(
                            Icons.monitor_weight_outlined,
                            "Current Weight",
                            "${(batch.rawWeight - batch.predictedWaste).toStringAsFixed(1)} kg",
                          ),
                        ),
                        Expanded(
                          child: monitoringTile(
                            Icons.trending_down_rounded,
                            "Weight Loss",
                            "${batch.predictedWaste.toStringAsFixed(1)} kg",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: monitoringTile(
                            Icons.percent_rounded,
                            "Loss Percentage",
                            "${batch.wastePercentage.toStringAsFixed(1)}%",
                          ),
                        ),
                        Expanded(
                          child: monitoringTile(
                            Icons.verified_user_outlined,
                            "Quality Status",
                            batch.status,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),

              // 5. Notification Information
              _buildSectionCard(
                title: "5. Notification Information",
                child: Row(
                  children: [
                    Expanded(
                      child: infoTile(
                        Icons.notifications_active_outlined,
                        "Waste Notification",
                        "Sent",
                      ),
                    ),
                    Expanded(
                      child: infoTile(
                        Icons.people_outline_rounded,
                        "Recipient",
                        "Fish Meal Company",
                      ),
                    ),
                    Expanded(
                      child: infoTile(
                        Icons.chat_bubble_outline_rounded,
                        "Channel",
                        "In-App, SMS",
                      ),
                    ),
                  ],
                ),
              ),

              // 6. Drying Process — live drying dashboard for this batch.
              DryingProcessCard(batchId: batch.batchId),

              const SizedBox(height: 4),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final saltedCompleted =
                        await DryingService.isSaltingCompleted(batch.batchId);
                    if (!context.mounted) return;

                    if (!saltedCompleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Complete the salting process before predicting drying time.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final cleanedWeight =
                        (batch.rawWeight - batch.predictedWaste).clamp(0.0, double.infinity);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TimePredictionScreen(
                          batchId: batch.batchId,
                          fishType: batch.fishType,
                          initialWeightKg: cleanedWeight,
                          saltedCompleted: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text(
                    'Time Prediction Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Back",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        backgroundColor: AppColors.button,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
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
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
                      label: const Text(
                        "Export Report",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              const Center(
                child: Text(
                  "Powered by Smart Karawala",
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  static Widget infoTile(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  static Widget predictionTile(
    IconData icon,
    String title,
    String value,
    String percent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            percent,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget monitoringTile(IconData icon, String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
