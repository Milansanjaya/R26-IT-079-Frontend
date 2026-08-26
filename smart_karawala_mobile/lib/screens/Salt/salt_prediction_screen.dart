import 'package:flutter/material.dart';
import '../../models/batch_model.dart';
import '../../models/salt_prediction_model.dart';
import '../../services/Salt/salt_service.dart';
import '../../widgets/Batch/colors.dart';
import '../../widgets/Batch/cleaned_weight_card.dart';
import '../../widgets/Prediction/prediction_result_card.dart';
import '../../services/Salt/salting_service.dart';
import 'salting_monitoring_screen.dart';
import '../admin/admin_home_screen.dart';

class SaltPredictionScreen extends StatefulWidget {
  final String? batchId;

  const SaltPredictionScreen({
    super.key,
    this.batchId,
  });

  @override
  State<SaltPredictionScreen> createState() => _SaltPredictionScreenState();
}

class _SaltPredictionScreenState extends State<SaltPredictionScreen> {
  BatchModel? batch;
  SaltPredictionModel? prediction;

  bool loading = true;
  bool predicting = false;

  @override
  void initState() {
    super.initState();
    loadLatestBatch();
  }

  Future<void> loadLatestBatch() async {
    try {
      final latest = (widget.batchId != null && widget.batchId!.isNotEmpty)
          ? await SaltService.getBatchById(widget.batchId!)
          : await SaltService.getLatestBatch();

      setState(() {
        batch = latest;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> predictSalt() async {
    if (batch == null) return;

    setState(() {
      predicting = true;
    });

    try {
      final result = await SaltService.predictSalt(batch!);

      setState(() {
        prediction = result;
        predicting = false;
      });
    } catch (e) {
      setState(() {
        predicting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
                "Salt Prediction",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Cleaned Weight Card
              CleanedWeightCard(
                batchId: batch!.batchId,
                fishType: batch!.fishType,
                cleanedWeight: batch!.cleanedWeight,
              ),

              const SizedBox(height: 24),

              // Predict Button
              if (prediction == null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: predicting ? null : predictSalt,
                    icon: predicting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(Icons.analytics_outlined, color: Colors.white),
                    label: Text(
                      predicting ? "Predicting..." : "Predict Salt",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

              // Prediction Result Card
              if (prediction != null) ...[
                PredictionResultCard(
                  saltAmount: prediction!.saltAmount,
                  saltingDurationHours: prediction!.saltingDurationHours,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            prediction = null;
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                        label: const Text(
                          "Reset",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(0, 56),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (batch == null) return;

                          final success = await SaltingService.startSalting(
                            batch!.batchId,
                          );

                          if (!mounted) return;

                          if (success) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SaltingMonitoringScreen(
                                  batchId: batch!.batchId,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to start salting"),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        label: const Text(
                          "Proceed",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(0, 56),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
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
}
