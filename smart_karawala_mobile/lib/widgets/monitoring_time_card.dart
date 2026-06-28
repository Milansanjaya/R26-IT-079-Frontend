import 'package:flutter/material.dart';

class MonitoringTimeCard extends StatelessWidget {

  final double remainingHours;

  const MonitoringTimeCard({
    super.key,
    required this.remainingHours,
  });

  String formatTime(double hours){

    final totalSeconds =
        (hours * 3600).toInt();

    final h = totalSeconds ~/ 3600;

    final m =
        (totalSeconds % 3600) ~/ 60;

    final s =
        totalSeconds % 60;

    return "${h.toString().padLeft(2,'0')}:"
        "${m.toString().padLeft(2,'0')}:"
        "${s.toString().padLeft(2,'0')}";
  }

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.access_time_filled,
              size: 40,
              color: Colors.blue,
            ),

            const SizedBox(height: 10),

            const Text(
              "Time Remaining",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              formatTime(remainingHours),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}