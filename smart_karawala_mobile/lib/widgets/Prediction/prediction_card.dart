import 'package:flutter/material.dart';
import '../../models/batch_model.dart';

class PredictionCard extends StatelessWidget {
  final BatchModel batch;

  const PredictionCard({
    super.key,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {

    final wastePercent =
        batch.rawWeight == 0
            ? 0
            : (batch.predictedWaste / batch.rawWeight) * 100;

    final cleanedPercent =
        batch.rawWeight == 0
            ? 0
            : (batch.cleanedWeight / batch.rawWeight) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),

      child: Column(
        children: [

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Prediction Result",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green,
                      width: 8,
                    ),
                  ),

                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [

                        Text(
                          batch.predictedWaste.toStringAsFixed(3),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Text("kg"),

                        const SizedBox(height: 8),

                        Text(
                          "${wastePercent.toStringAsFixed(1)}%",
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

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  children: [

                    _box(
                      Icons.delete,
                      "Predicted Waste",
                      "${batch.predictedWaste.toStringAsFixed(3)} kg",
                      "${wastePercent.toStringAsFixed(1)}%",
                    ),

                    const SizedBox(height: 15),

                    _box(
                      Icons.set_meal,
                      "Cleaned Weight",
                      "${batch.cleanedWeight.toStringAsFixed(3)} kg",
                      "${cleanedPercent.toStringAsFixed(1)}%",
                    ),

                  ],
                ),
              ),

            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffEAFBEA),
              borderRadius: BorderRadius.circular(15),
            ),

            child: const Row(
              children: [

                Icon(
                  Icons.verified,
                  color: Colors.green,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "High confidence prediction (92%)",
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(
      IconData icon,
      String title,
      String value,
      String percent) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffEEF5FF),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        children: [

          Icon(icon, color: Colors.blue),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.blue,
            ),
          ),

          Text(
            percent,
            style: const TextStyle(
              color: Colors.green,
            ),
          ),

        ],
      ),
    );
  }
}