import 'package:flutter/material.dart';

class ProcessingRecordCard extends StatelessWidget {
  final String batchId;
  final String fishType;
  final String date;
  final String time;
  final String status;

  const ProcessingRecordCard({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.date,
    required this.time,
    required this.status,
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
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: status.toLowerCase() == "completed"
                    ? Colors.green.shade50
                    : status.toLowerCase().contains("progress")
                    ? Colors.orange.shade50
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: status.toLowerCase() == "completed"
                      ? Colors.green
                      : status.toLowerCase().contains("progress")
                      ? Colors.orange
                      : Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
