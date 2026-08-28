import 'package:flutter/material.dart';
import '../../utils/weight_formatter.dart';

class PredictionResultCard extends StatelessWidget {
  final double saltAmount;
  final int saltingDurationHours;

  const PredictionResultCard({
    super.key,
    required this.saltAmount,
    required this.saltingDurationHours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [

              Icon(
                Icons.analytics,
                color: Colors.blue,
              ),

              SizedBox(width: 8),

              Text(
                "Prediction Results",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              //------------------------------------------------
              // Salt Amount
              //------------------------------------------------

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xffEEF8FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [

                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.water_drop,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Recommended\nSalt Amount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        WeightFormatter.format(saltAmount),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(width: 15),

              //------------------------------------------------
              // Duration
              //------------------------------------------------

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF8E7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [

                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.orange,
                        child: Icon(
                          Icons.schedule,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Recommended\nDuration",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "$saltingDurationHours Hours",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),

                    ],
                  ),
                ),
              ),

            ],
          ),

          const SizedBox(height: 20),

          //------------------------------------------------
          // Recommendation Note
          //------------------------------------------------

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xffF8FFF2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.green.shade200,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Icon(
                  Icons.lightbulb,
                  color: Colors.green,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Use ${saltAmount.toStringAsFixed(2)} kg of salt and keep the fish in the salting process for $saltingDurationHours hours for the best quality.",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}