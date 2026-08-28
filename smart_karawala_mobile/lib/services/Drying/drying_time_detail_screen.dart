import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/drying_model.dart';
import '../../services/Drying/drying_service.dart';
import '../../widgets/Drying/drying_process_card.dart'
    show kDryingSensorRefreshInterval;
import '../../widgets/Drying/factor_tile.dart';

/// Explains HOW the remaining drying time is estimated: the headline estimate
/// plus each reading/factor that feeds the model with its current vs expected
/// level and effect on the time.
class DryingTimeDetailScreen extends StatefulWidget {
  const DryingTimeDetailScreen({super.key});

  @override
  State<DryingTimeDetailScreen> createState() => _DryingTimeDetailScreenState();
}

class _DryingTimeDetailScreenState extends State<DryingTimeDetailScreen> {
  DryingTimeResult? _time;
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
      final t = await DryingService.getDryingTime();
      if (!mounted) return;
      setState(() {
        // Keep the last good reading when the IoT weight drops out (backend
        // then returns a factor-less "SeededEstimate"/"Unavailable" result).
        final isUnavailable = t.factors.isEmpty &&
            (t.modelUsed == "Unavailable" || t.modelUsed == "SeededEstimate");
        if (!isUnavailable || _time == null) {
          _time = t;
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

  String _formatHm(double hours) {
    final total = (hours * 3600).round();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    return "${h}h ${m}min";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text("Drying Time",
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
    final t = _time!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estimate banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text("Estimated Time Remaining",
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                const SizedBox(height: 10),
                Text(
                  _formatHm(t.predictedRemainingHours),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text("Model: ${t.modelUsed}",
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text("How is this estimated?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(
            "The model combines the readings below. Each shows its current value, "
            "its normal range, and how it lengthens or shortens the estimate.",
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          if (t.factors.isEmpty)
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
            ...t.factors.map((f) => FactorTile(factor: f)),
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
