import 'package:flutter/material.dart';

class MonitoringProgressCard extends StatelessWidget {
  final double progress;

  const MonitoringProgressCard({
    super.key,
    required this.progress,
  });

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

            const Text(
              "Progress",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [

                  CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 7,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        const AlwaysStoppedAnimation(
                      Colors.green,
                    ),
                  ),

                  Text(
                    "${progress.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}