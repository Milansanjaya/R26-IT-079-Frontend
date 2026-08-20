import 'package:flutter/material.dart';

/// The dry-fish batch lifecycle, as a single clear stage derived from the
/// batch's existing fields (no schema change). Order reflects the real process:
///
///   Created → Salt Predicted → Salting (8h soak) → Salted (ready to dry)
///   → Drying → Dispatched
///
/// This replaces showing the raw `saltingStatus` (not_started / In Progress /
/// completed), which was ambiguous — "completed" only meant salting was done,
/// not that the whole batch was finished.
enum BatchStage {
  created,
  saltPredicted,
  salting,
  salted,
  drying,
  dispatched;

  /// Short, human label shown on the chip.
  String get label {
    switch (this) {
      case BatchStage.created:
        return "Created";
      case BatchStage.saltPredicted:
        return "Salt Predicted";
      case BatchStage.salting:
        return "Salting";
      case BatchStage.salted:
        return "Salted · Ready to Dry";
      case BatchStage.drying:
        return "Drying";
      case BatchStage.dispatched:
        return "Dispatched";
    }
  }

  /// One-line description for detail views.
  String get description {
    switch (this) {
      case BatchStage.created:
        return "Batch created. Next: predict salt.";
      case BatchStage.saltPredicted:
        return "Salt amount & duration predicted. Next: start salting.";
      case BatchStage.salting:
        return "Salting in progress (soaking). Wait for it to complete.";
      case BatchStage.salted:
        return "Salting complete. Ready to start drying.";
      case BatchStage.drying:
        return "Drying in the IoT oven.";
      case BatchStage.dispatched:
        return "Completed and dispatched to market.";
    }
  }

  Color get color {
    switch (this) {
      case BatchStage.created:
        return const Color(0xFF7F93A8); // slate
      case BatchStage.saltPredicted:
        return const Color(0xFF3D7EDB); // blue
      case BatchStage.salting:
        return const Color(0xFFF5A623); // amber (in-progress soak)
      case BatchStage.salted:
        return const Color(0xFF0A9396); // teal (ready)
      case BatchStage.drying:
        return const Color(0xFFE07B00); // warm orange (heat/drying)
      case BatchStage.dispatched:
        return const Color(0xFF2EAD4B); // green (done)
    }
  }

  IconData get icon {
    switch (this) {
      case BatchStage.created:
        return Icons.inventory_2_outlined;
      case BatchStage.saltPredicted:
        return Icons.science_outlined;
      case BatchStage.salting:
        return Icons.opacity_rounded;
      case BatchStage.salted:
        return Icons.check_circle_outline_rounded;
      case BatchStage.drying:
        return Icons.wb_sunny_outlined;
      case BatchStage.dispatched:
        return Icons.local_shipping_outlined;
    }
  }

  /// Derive the stage from a batch's fields.
  ///
  /// [saltingStatus] is the batch's raw saltingStatus.
  /// [saltAmount]/[recommendedDuration] indicate a salt prediction was made.
  /// [isDrying] — true if this batch is currently the active drying batch
  ///   (known from the drying service). Overrides salting-derived stages.
  /// [isDispatched] — true if the batch has been dispatched to market.
  static BatchStage derive({
    String? saltingStatus,
    double saltAmount = 0,
    double recommendedDuration = 0,
    bool isDrying = false,
    bool isDispatched = false,
  }) {
    if (isDispatched) return BatchStage.dispatched;
    if (isDrying) return BatchStage.drying;

    final s = (saltingStatus ?? "").trim().toLowerCase();

    if (s.startsWith("complete")) return BatchStage.salted;
    if (s.contains("progress")) return BatchStage.salting;

    // Not salting yet — distinguish "created" from "salt predicted".
    if (saltAmount > 0 || recommendedDuration > 0) {
      return BatchStage.saltPredicted;
    }
    return BatchStage.created;
  }

  /// Convenience for the traceability list, which only carries the raw status
  /// string (mapped from saltingStatus). Best-effort mapping.
  static BatchStage fromStatusString(String status, {bool isDrying = false}) {
    return derive(saltingStatus: status, isDrying: isDrying);
  }
}
