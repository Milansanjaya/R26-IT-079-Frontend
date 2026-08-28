import 'package:flutter/material.dart';
import '../../models/drying_model.dart';

/// One IoT reading / derived factor rendered as a row: current value vs the
/// expected/normal range, a status chip (good/elevated/high/low), and a plain
/// explanation of how it affects the result. Shared by the detail screens.
class FactorTile extends StatelessWidget {
  final PredictionFactor factor;

  const FactorTile({super.key, required this.factor});

  ({Color color, Color bg, String label}) get _statusStyle {
    switch (factor.status) {
      case "high":
        return (color: const Color(0xFFE53935), bg: const Color(0xFFFFF1F0), label: "HIGH");
      case "elevated":
        return (color: const Color(0xFFF5A623), bg: const Color(0xFFFFF8E8), label: "ELEVATED");
      case "low":
        return (color: const Color(0xFF3D7EDB), bg: const Color(0xFFEDF4FF), label: "LOW");
      default:
        return (color: const Color(0xFF2EAD4B), bg: const Color(0xFFF1FFF3), label: "NORMAL");
    }
  }

  String get _valueText {
    final v = factor.value;
    final asInt = v == v.roundToDouble();
    final num = asInt ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return factor.unit.isEmpty ? num : "$num ${factor.unit}";
  }

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  factor.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF234B69),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: s.color.withOpacity(0.3)),
                ),
                child: Text(
                  s.label,
                  style: TextStyle(
                    color: s.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Current vs expected
          Row(
            children: [
              Expanded(
                child: _metric("Current", _valueText, s.color, bold: true),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              Expanded(
                child: _metric("Expected", factor.normalRange, Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Effect explanation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 15, color: s.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  factor.effect,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color valueColor, {bool bold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
