import 'package:flutter/material.dart';

class MonitoringWeightCard extends StatelessWidget {

  final double weightLoss;
  final double percentage;

  const MonitoringWeightCard({
    super.key,
    required this.weightLoss,
    required this.percentage,
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
          mainAxisSize: MainAxisSize.min,
          children: [

            const Icon(
              Icons.scale,
              size: 32,
              color: Colors.orange,
            ),

            const SizedBox(height: 6),

            const Text(
              "Weight Loss",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "${weightLoss.toStringAsFixed(1)} kg",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            Text(
              "${percentage.toStringAsFixed(1)}%",
            ),
          ],
        ),
      ),
    );
  }
}