import 'package:flutter/material.dart';

class MonitoringRecommendationCard extends StatelessWidget {
  final String status;

  const MonitoringRecommendationCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String message;

    switch (status) {
      case "Completed":
        message =
            "Salting process is complete. You can proceed to the drying stage.";
        break;

      case "Warning":
        message =
            "Check the batch immediately. The monitoring values are outside the normal range.";
        break;

      default:
        message =
            "Continue monitoring. The salting process is progressing normally.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffFFF9E6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb,
            color: Colors.orange,
            size: 30,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recommended Action",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}