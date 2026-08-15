import 'package:flutter/material.dart';

/// Central spoilage-risk indicator. Severity is encoded in colour AND form
/// (badge, icon, ring) so the state reads at a glance:
///   Low = green, Medium = amber, High = red.
class SpoilageRiskCard extends StatelessWidget {
  final String spoilageRisk; // High | Medium | Low
  final String smellLevel;
  final String modelUsed;

  const SpoilageRiskCard({
    super.key,
    required this.spoilageRisk,
    required this.smellLevel,
    required this.modelUsed,
  });

  _RiskStyle get _style {
    switch (spoilageRisk.toLowerCase()) {
      case "high":
        return _RiskStyle(
          color: const Color(0xFFE53935),
          bg: const Color(0xFFFFF1F0),
          icon: Icons.gpp_bad_rounded,
          message: "High spoilage risk — inspect the batch immediately.",
        );
      case "medium":
        return _RiskStyle(
          color: const Color(0xFFF5A623),
          bg: const Color(0xFFFFF8E8),
          icon: Icons.gpp_maybe_rounded,
          message: "Moderate risk — keep monitoring drying conditions.",
        );
      default: // Low
        return _RiskStyle(
          color: const Color(0xFF2EAD4B),
          bg: const Color(0xFFF1FFF3),
          icon: Icons.verified_user_rounded,
          message: "Low risk — the batch is drying safely.",
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.color.withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          // Risk ring
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: s.color, width: 5),
              boxShadow: [
                BoxShadow(
                  color: s.color.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(s.icon, color: s.color, size: 34),
                const SizedBox(height: 4),
                Text(
                  spoilageRisk.toUpperCase(),
                  style: TextStyle(
                    color: s.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Spoilage Risk Level",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            s.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _pill(
                  "Smell Level",
                  smellLevel,
                  Icons.air_rounded,
                  s.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _pill(
                  "Model",
                  modelUsed,
                  Icons.psychology_alt_rounded,
                  s.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  final String message;

  _RiskStyle({
    required this.color,
    required this.bg,
    required this.icon,
    required this.message,
  });
}
