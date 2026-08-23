import 'package:flutter/material.dart';
import '../../utils/weight_formatter.dart';

class MonitoringWeightCard extends StatelessWidget {
  final double currentWeight;
  final double cleanedWeight;
  final double weightLoss;
  final double percentage;

  const MonitoringWeightCard({
    super.key,
    required this.currentWeight,
    this.cleanedWeight = 0.0,
    this.weightLoss = 0.0,
    this.percentage = 0.0,
  });

  String _formatWeight(double w) {
    return WeightFormatter.format(w);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.scale_rounded,
              size: 28,
              color: Colors.orange,
            ),
            const SizedBox(height: 4),
            const Text(
              "Current Weight",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatWeight(currentWeight),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0F172A),
              ),
            ),
            if (cleanedWeight > 0) ...[
              const SizedBox(height: 3),
              Text(
                "Cleaned: ${_formatWeight(cleanedWeight)}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}