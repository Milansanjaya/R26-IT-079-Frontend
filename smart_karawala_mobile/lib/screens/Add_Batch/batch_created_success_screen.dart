import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import '../admin/admin_home_screen.dart';
import '../Waste/waste_prediction_screen.dart';
import 'add_new_batch_screen.dart';

class BatchCreatedSuccessScreen extends StatelessWidget {
  final String batchId;
  final String fishType;
  final String rawWeight;
  final String date;
  final String time;
  final String location;
  final String notes;

  const BatchCreatedSuccessScreen({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.rawWeight,
    required this.date,
    required this.time,
    required this.location,
    required this.notes,
  });

  Widget _buildDetailRow(String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value.isEmpty ? "N/A" : value,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(color: Colors.grey.shade100, height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 32),

                // Success checkmark illustration
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  "Batch Created Successfully!",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  "Your new batch has been created and saved.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Details Card
                Container(
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
                  child: Column(
                    children: [
                      _buildDetailRow("Batch ID", batchId),
                      _buildDetailRow("Fish Type", fishType),
                      _buildDetailRow("Raw Weight", "$rawWeight kg"),
                      _buildDetailRow("Date", date),
                      _buildDetailRow("Time", time),
                      _buildDetailRow("Location", location),
                      _buildDetailRow("Notes", notes, showDivider: false),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_delete_outlined, color: Colors.white),
                  label: const Text(
                    "Waste Prediction",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WastePredictionScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: const Text(
                    "Create Another Batch",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddNewBatchScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}