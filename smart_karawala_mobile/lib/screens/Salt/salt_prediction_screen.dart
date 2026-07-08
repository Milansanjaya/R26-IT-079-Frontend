import 'package:flutter/material.dart';

import '../../models/batch_model.dart';
import '../../models/salt_prediction_model.dart';
import '../../services/Salt/salt_service.dart';

import '../../widgets/Batch/cleaned_weight_card.dart';
import '../../widgets/Prediction/prediction_result_card.dart';

import '../../services/Salt/salting_service.dart';
import 'salting_monitoring_screen.dart';

class SaltPredictionScreen extends StatefulWidget {
  const SaltPredictionScreen({super.key});

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

  //------------------------------------------------
  // Load latest batch
  //------------------------------------------------

  Future<void> loadLatestBatch() async {
    try {
      final latest = await SaltService.getLatestBatch();

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

  //------------------------------------------------
  // Predict Salt
  //------------------------------------------------

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
  //------------------------------------------------
  // UI
  //------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffEAF7FF),
        centerTitle: true,
        title: const Text(
          "Salt Prediction",
          style: TextStyle(
            color: Color(0xff214E77),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff214E77)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------------------------------------
            // Cleaned Weight Card
            //------------------------------------------------
            CleanedWeightCard(
              batchId: batch!.batchId,
              fishType: batch!.fishType,
              cleanedWeight: batch!.cleanedWeight,
            ),

            const SizedBox(height: 25),

            //------------------------------------------------
            // Predict Button
            //------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: predicting ? null : predictSalt,

                icon: predicting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.analytics),

                label: Text(predicting ? "Predicting..." : "Predict Salt"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff214E77),
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 25),

            //------------------------------------------------
            // Prediction Result
            //------------------------------------------------
            if (prediction != null)
              PredictionResultCard(
                saltAmount: prediction!.saltAmount,
                saltingDurationHours: prediction!.saltingDurationHours,
              ),

            const SizedBox(height: 30),

            //------------------------------------------------
            // Action Buttons
            //------------------------------------------------
            if (prediction != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          prediction = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reset"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

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

                      icon: const Icon(Icons.arrow_forward),

                      label: const Text("Proceed"),

                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 25),

            //------------------------------------------------
            // Recommendation
            //------------------------------------------------
            if (prediction != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffF3FFF3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.green),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        "Recommended salt amount is "
                        "${prediction!.saltAmount.toStringAsFixed(2)} kg.\n\n"
                        "Recommended salting duration is "
                        "${prediction!.saltingDurationHours} hours.",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
