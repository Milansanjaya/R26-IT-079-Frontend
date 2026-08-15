import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Large countdown-style card showing predicted remaining drying time.
class DryingTimeCard extends StatelessWidget {
  final double remainingHours;
  final String modelUsed;

  const DryingTimeCard({
    super.key,
    required this.remainingHours,
    required this.modelUsed,
  });

  /// Split into H / M for a clean two-part readout.
  (int, int) _hm(double hours) {
    final total = (hours * 3600).round();
    return (total ~/ 3600, (total % 3600) ~/ 60);
  }

  @override
  Widget build(BuildContext context) {
    final (h, m) = _hm(remainingHours);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.timelapse_rounded,
                  color: Color(0xFFFF7043), size: 22),
              SizedBox(width: 8),
              Text(
                "Estimated Time Remaining",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _timeBlock(h.toString().padLeft(2, '0'), "hours"),
              const Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: Text(
                  ":",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _timeBlock(m.toString().padLeft(2, '0'), "min"),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology_alt_rounded,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  "Model: $modelUsed",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBlock(String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.0,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
