import 'package:flutter/material.dart';
import '../../core/batch_stage.dart';
import '../Batch/batch_stage_chip.dart';

class ProcessingRecordCard extends StatelessWidget {
  final String batchId;
  final String fishType;
  final String date;
  final String time;
  final String status;
  final VoidCallback? onTap;

  const ProcessingRecordCard({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.date,
    required this.time,
    required this.status,
    this.onTap,
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: BatchStageChip(
                stage: BatchStage.fromStatusString(status),
                compact: true,
              ),
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: onTap,
            child: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
