import 'package:flutter/material.dart';
import '../../models/batch_model.dart';
import '../../services/Batch/batch_service.dart';
import '../../widgets/Batch/colors.dart';
import '../../utils/weight_formatter.dart';
import 'waste_notification_screen.dart';
import '../admin/admin_home_screen.dart';
import '../Salt/salt_prediction_screen.dart';

class WastePredictionScreen extends StatefulWidget {
  final String? batchId;

  const WastePredictionScreen({
    super.key,
    this.batchId,
  });

  @override
  State<WastePredictionScreen> createState() => _WastePredictionScreenState();
}

class _WastePredictionScreenState extends State<WastePredictionScreen> {
  bool loading = true;
  bool predicting = false;
  bool hasPredicted = false;

  BatchModel? batch;

  @override
  void initState() {
    super.initState();
    loadLatestBatch();
  }

  Future<void> loadLatestBatch() async {
    try {
      final latest = (widget.batchId != null && widget.batchId!.isNotEmpty)
          ? await BatchService.getBatchById(widget.batchId!)
          : await BatchService.getLatestBatch();

      setState(() {
        batch = latest;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> predictWaste() async {
    if (batch == null) return;

    setState(() {
      predicting = true;
    });

    try {
      await BatchService.predictWaste(batch!.batchId);
      await loadLatestBatch();
      if (mounted) {
        setState(() {
          hasPredicted = true;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;

    setState(() {
      predicting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (batch == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text(
            "No batch found",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
      );
    }

    final double wastePercentage = batch!.rawWeight > 0
        ? (batch!.predictedWaste / batch!.rawWeight) * 100
        : 0.0;

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
                          builder: (_) => const AdminHomeScreen(),
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
                "Waste Prediction",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Batch Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Detail items
                    _buildSummaryRow("Batch ID", batch!.batchId),
                    const Divider(height: 24),
                    _buildSummaryRow("Fish Type", batch!.fishType),
                    const Divider(height: 24),
                    _buildSummaryRow("Raw Fish Weight", WeightFormatter.format(batch!.rawWeight)),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: predicting ? null : predictWaste,
                        child: predicting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.analytics_outlined),
                                  SizedBox(width: 8),
                                  Text(
                                    "Predict Waste",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasPredicted) ...[
                const SizedBox(height: 24),

                // Prediction Result Heading
                const Text(
                  "Prediction Result",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Prediction Result Container
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
                    children: [
                      // Circular progress ring on the left
                      Expanded(
                        flex: 6,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 130,
                                width: 130,
                                child: CircularProgressIndicator(
                                  value: batch!.rawWeight > 0 ? (batch!.predictedWaste / batch!.rawWeight) : 0,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    WeightFormatter.format(batch!.predictedWaste),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${wastePercentage.toStringAsFixed(1)}%",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Information details on the right
                      Expanded(
                        flex: 7,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F9FD),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade50),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.delete_sweep_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Predicted Waste",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                WeightFormatter.format(batch!.predictedWaste),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${wastePercentage.toStringAsFixed(1)}% of raw weight",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Calculate predicted waste in kg for 1 kg threshold check
                Builder(
                  builder: (context) {
                    final double rawPredictedWaste = batch!.predictedWaste;
                    final double predictedWasteKg = rawPredictedWaste > 100 ? rawPredictedWaste / 1000.0 : rawPredictedWaste;
                    final bool isBelowThreshold = predictedWasteKg < 1.0;

                    if (isBelowThreshold) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0), // Soft warning amber background
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.shade300, width: 1.5),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Collection Threshold Notice",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade900,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Predicted waste is below the 1 kg collection threshold. No recycling notification is required.",
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Next Step: Salt Prediction Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaltPredictionScreen(
                                      batchId: batch!.batchId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.opacity_rounded, color: Colors.white),
                              label: const Text(
                                "Next Step: Salt Prediction",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        // Next Step Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD), // Soft blue background
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade100, width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded, color: Colors.blue.shade800, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Next Step",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "After predicting the waste amount, notify the recycling partners so they can collect the fish waste for recycling.",
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Send Notification Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final result = await BatchService.sendNotificationResult(
                                batch!.batchId,
                              );

                              if (!mounted) return;

                              if (result["success"] == true) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WasteNotificationScreen(
                                      predictedWaste: predictedWasteKg,
                                      batchId: batch!.batchId,
                                      wastePercentage: wastePercentage,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(result["message"] ?? "Failed to send notification."),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.send_rounded, color: Colors.white),
                            label: const Text(
                              "Send Notification",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],

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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
