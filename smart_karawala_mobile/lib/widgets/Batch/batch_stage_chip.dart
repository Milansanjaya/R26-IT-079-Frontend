import 'package:flutter/material.dart';
import '../../core/batch_stage.dart';

/// A clear, color-coded lifecycle chip for a batch (Created / Salt Predicted /
/// Salting / Salted / Drying / Dispatched). Use in lists and detail headers so
/// the batch's real stage is obvious at a glance.
class BatchStageChip extends StatelessWidget {
  final BatchStage stage;
  final bool compact;

  const BatchStageChip({super.key, required this.stage, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: stage.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stage.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stage.icon, size: compact ? 12 : 14, color: stage.color),
          SizedBox(width: compact ? 4 : 6),
          Flexible(
            child: Text(
              stage.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: stage.color,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 10.5 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
