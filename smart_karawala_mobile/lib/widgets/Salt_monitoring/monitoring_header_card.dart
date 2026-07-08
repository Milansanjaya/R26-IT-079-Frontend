import 'package:flutter/material.dart';

class MonitoringHeaderCard extends StatelessWidget {
  final String batchId;
  final String fishType;
  final String startTime;
  final String status;

  const MonitoringHeaderCard({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.startTime,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //-------------------------------------------------
          // Batch ID
          //-------------------------------------------------
          Expanded(
            child: ExcludeFocus(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long, color: Colors.blue),
                  const SizedBox(height: 5),
                  const Text(
                    "Batch ID",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    batchId,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //-------------------------------------------------
          // Fish Type
          //-------------------------------------------------
          Expanded(
            child: ExcludeFocus(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.set_meal, color: Colors.indigo),
                  const SizedBox(height: 5),
                  const Text(
                    "Fish Type",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    fishType,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //-------------------------------------------------
          // Start Time
          //-------------------------------------------------
          Expanded(
            child: ExcludeFocus(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(height: 5),
                  const Text(
                    "Start Time",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    startTime.replaceFirst("T", "\n").substring(0, 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          //-------------------------------------------------
          // Status
          //-------------------------------------------------
          Expanded(
            child: ExcludeFocus(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timelapse, color: Colors.blue),
                  const SizedBox(height: 5),
                  const Text(
                    "Status",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: status == "Completed"
                          ? Colors.green
                          : Colors.orange,
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
