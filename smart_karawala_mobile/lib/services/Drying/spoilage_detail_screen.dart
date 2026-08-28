import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/drying_model.dart';
import 'drying_service.dart';
import '../../widgets/Drying/drying_process_card.dart'
    show kDryingSensorRefreshInterval;
import '../../widgets/Drying/factor_tile.dart';

/// Explains WHY the active batch has its current spoilage risk: the headline
/// verdict plus each IoT reading with its current vs expected level and effect.
class SpoilageDetailScreen extends StatefulWidget {
  const SpoilageDetailScreen({super.key});

  @override
  State<SpoilageDetailScreen> createState() => _SpoilageDetailScreenState();
}

class _SpoilageDetailScreenState extends State<SpoilageDetailScreen> {
  SpoilageRiskResult? _risk;
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer =
        Timer.periodic(kDryingSensorRefreshInterval, (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final r = await DryingService.getSpoilageRisk();
      if (!mounted) return;
      setState(() {
        // The IoT weight reading drops out intermittently; when it does the
        // backend returns an "Unavailable" result with no factors. Keep the
        // last good reading on screen rather than blanking it out - the next
        // refresh usually recovers within seconds.
        final isUnavailable =
            r.modelUsed == "Unavailable" || r.factors.isEmpty;
        if (!isUnavailable || _risk == null) {
          _risk = r;
        }
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "").trim();
        _loading = false;
      });
    }
  }

  ({Color color, Color bg, IconData icon, String headline}) _style(String risk) {
    switch (risk.toLowerCase()) {
      case "high":
        return (
          color: const Color(0xFFE53935),
          bg: const Color(0xFFFFF1F0),
          icon: Icons.gpp_bad_rounded,
          headline: "High spoilage risk — inspect the batch now."
        );
      case "medium":
        return (
          color: const Color(0xFFF5A623),
          bg: const Color(0xFFFFF8E8),
          icon: Icons.gpp_maybe_rounded,
          headline: "Moderate risk — keep monitoring conditions."
        );
      default:
        return (
          color: const Color(0xFF2EAD4B),
          bg: const Color(0xFFF1FFF3),
          icon: Icons.verified_user_rounded,
          headline: "Low risk — the batch is drying safely."
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text("Spoilage Risk",
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _errorView()
              : _content(),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sensors_off_rounded, size: 46, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );

  Widget _content() {
    final r = _risk!;
    final s = _style(r.spoilageRisk);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verdict banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: s.bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: s.color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: s.color, width: 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.icon, color: s.color, size: 26),
                      const SizedBox(height: 2),
                      Text(r.spoilageRisk.toUpperCase(),
                          style: TextStyle(color: s.color, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(s.headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text("Smell level: ${r.smellLevel}  •  Model: ${r.modelUsed}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text("Why this level?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(
            "Each IoT reading below is compared to its expected range. "
            "Readings outside the range push the risk up.",
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          if (r.factors.isEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sensors_off_rounded,
                    size: 18, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Waiting for a complete IoT sensor reading. This usually "
                    "recovers within a few seconds.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                  ),
                ),
              ],
            )
          else
            ...r.factors.map((f) => FactorTile(factor: f)),
          const SizedBox(height: 16),
          Center(
            child: Text(
                "Auto-updates every ${kDryingSensorRefreshInterval.inSeconds}s from IoT sensors",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
