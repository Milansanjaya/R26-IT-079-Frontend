import 'package:flutter/material.dart';
import '../models/batch_model.dart';
import '../services/batch_service.dart';
import 'waste_notification_screen.dart';

class WastePredictionScreen extends StatefulWidget {
  const WastePredictionScreen({super.key});

  @override
  State<WastePredictionScreen> createState() => _WastePredictionScreenState();
}

class _WastePredictionScreenState extends State<WastePredictionScreen> {
  bool loading = true;
  bool predicting = false;

  BatchModel? batch;

  @override
  void initState() {
    super.initState();
    loadLatestBatch();
  }

  Future<void> loadLatestBatch() async {
    try {
      final latest = await BatchService.getLatestBatch();

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (batch == null) {
      return const Scaffold(body: Center(child: Text("No batch found")));
    }

    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            children: [
              //--------------------------------------------------
              // Header
              //--------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xff174C7B),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Column(
                    children: const [
                      Icon(Icons.set_meal, color: Colors.blue, size: 45),

                      Text(
                        "Smart",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text("කරවල"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Waste Prediction",

                style: TextStyle(
                  fontSize: 34,

                  color: Color(0xff174C7B),

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Batch Summary Card
              //--------------------------------------------------
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: const Color(0xffEEF5FF),

                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: const Icon(
                            Icons.assignment,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          "Batch Summary",

                          style: TextStyle(
                            fontSize: 18,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Fish Type",

                      style: TextStyle(color: Colors.grey.shade700),
                    ),

                    Text(
                      batch!.fishType,

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,

                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Raw Fish Weight",

                      style: TextStyle(color: Colors.grey.shade700),
                    ),

                    Text(
                      "${batch!.rawWeight} kg",

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,

                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,

                      height: 45,

                      child: ElevatedButton.icon(
                        onPressed: predicting ? null : predictWaste,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0A3E91),

                          foregroundColor: Colors.white,
                        ),

                        icon: predicting
                            ? const SizedBox(
                                height: 18,

                                width: 18,

                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.analytics),

                        label: Text(
                          predicting ? "Predicting..." : "Predict Waste",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Prediction Result
              //--------------------------------------------------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Prediction Result",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff174C7B),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //------------------------------------------------
                        // Waste Circle
                        //------------------------------------------------
                        Expanded(
                          child: Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green,
                                width: 10,
                              ),
                            ),

                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Text(
                                    "${batch!.predictedWaste}",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff174C7B),
                                    ),
                                  ),

                                  const Text(
                                    "kg",
                                    style: TextStyle(fontSize: 18),
                                  ),

                                  const SizedBox(height: 10),

                                  const Text(
                                    "Total Waste",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "${((batch!.predictedWaste / batch!.rawWeight) * 100).toStringAsFixed(1)} %",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        //------------------------------------------------
                        // Right Side Cards
                        //------------------------------------------------
                        Expanded(
                          child: Column(
                            children: [
                              //------------------------------------------------
                              // Predicted Waste Card
                              //------------------------------------------------
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),

                                decoration: BoxDecoration(
                                  color: const Color(0xffEEF5FF),
                                  borderRadius: BorderRadius.circular(15),
                                ),

                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline,
                                      color: Colors.blue,
                                      size: 30,
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      "Predicted Waste",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      "${batch!.predictedWaste} kg",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      "${((batch!.predictedWaste / batch!.rawWeight) * 100).toStringAsFixed(1)}% of raw weight",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Notification Information Card
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xffEEF5FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.blue),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Next Step",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "After predicting the waste amount, notify the recycling partners so they can collect the fish waste for recycling.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Send Notification Button
              //--------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0A3E91),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final success = await BatchService.sendNotification(
                      batch!.batchId,
                    );

                    if (!mounted) return;

                    if (success) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WasteNotificationScreen(
                            predictedWaste: batch!.predictedWaste,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Failed to send notification."),
                        ),
                      );
                    }

                    if (!mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Notification sent successfully."),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Failed to send notification."),
                        ),
                      );
                    }
                  },

                  icon: const Icon(Icons.send),

                  label: const Text(
                    "Send Notification",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              //--------------------------------------------------
              // Refresh Button
              //--------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 50,

                child: OutlinedButton.icon(
                  onPressed: loadLatestBatch,

                  icon: const Icon(Icons.refresh),

                  label: const Text(
                    "Refresh Prediction",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Divider(),

              const SizedBox(height: 15),

              const Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
