import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Batch identity banner shown at the top of the drying monitor screens.
class DryingHeaderCard extends StatelessWidget {
  final String batchId;
  final String fishType;
  final double initialWeightKg;
  final double elapsedHours;

  const DryingHeaderCard({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.initialWeightKg,
    required this.elapsedHours,
  });

  String _formatElapsed(double hours) {
    final total = (hours * 3600).toInt();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    return "${h}h ${m}m";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.wb_sunny_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batchId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fishType.isEmpty
                          ? "In drying oven"
                          : "${fishType[0].toUpperCase()}${fishType.substring(1)} • In drying oven",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat("Initial Weight",
                  "${initialWeightKg.toStringAsFixed(3)} kg", Icons.scale),
              Container(
                width: 1,
                height: 34,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              _stat("Elapsed", _formatElapsed(elapsedHours),
                  Icons.hourglass_bottom_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          const SizedBox(width: 4),
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
