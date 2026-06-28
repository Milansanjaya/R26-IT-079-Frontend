import 'package:flutter/material.dart';

class CleanedWeightCard extends StatelessWidget {
  final String batchId;
  final String fishType;
  final double cleanedWeight;

  const CleanedWeightCard({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.cleanedWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          //------------------------
          // Left Section
          //------------------------
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.green,
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cleaned Weight",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${cleanedWeight.toStringAsFixed(1)} kg",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "From Waste Prediction",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          //------------------------
          // Right Section
          //------------------------
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF6F9FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Color(0xff214E77),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Batch ID",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff214E77),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    batchId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Row(
                    children: [
                      Icon(
                        Icons.set_meal,
                        color: Color(0xff214E77),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Fish Type",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff214E77),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    fishType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}