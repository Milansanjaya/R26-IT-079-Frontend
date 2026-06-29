import 'package:flutter/material.dart';

class ProcessingRecordCard extends StatelessWidget {
  final String batchId;
  final String fishType;
  final String date;
  final String time;
  final double wasteKg;
  final double wastePercentage;

  const ProcessingRecordCard({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.date,
    required this.time,
    required this.wasteKg,
    required this.wastePercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batchId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff214E77),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fishType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Waste: ${wasteKg.toStringAsFixed(1)} kg\n(${wastePercentage.toStringAsFixed(0)}%)",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}