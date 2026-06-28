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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          //-------------------------------------------------
          // Batch ID
          //-------------------------------------------------
          Column(
            children: [
              const Icon(
                Icons.receipt_long,
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              const Text(
                "Batch ID",
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                batchId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          //-------------------------------------------------
          // Fish Type
          //-------------------------------------------------
          Column(
            children: [
              const Icon(
                Icons.set_meal,
                color: Colors.indigo,
              ),
              const SizedBox(height: 5),
              const Text(
                "Fish Type",
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                fishType,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          //-------------------------------------------------
          // Start Time
          //-------------------------------------------------
          Column(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              const Text(
                "Start Time",
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                startTime,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          //-------------------------------------------------
          // Status
          //-------------------------------------------------
          Column(
            children: [
              const Icon(
                Icons.timelapse,
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              const Text(
                "Status",
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                status,
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
        ],
      ),
    );
  }
}