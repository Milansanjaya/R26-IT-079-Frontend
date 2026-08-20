import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/drying_model.dart';
import '../../services/Drying/drying_service.dart';
import '../../services/Drying/spoilage_detail_screen.dart';
import '../../services/Drying/drying_time_detail_screen.dart';

/// Self-contained drying dashboard for a single batch, shown inside the
/// Batch Details page.
///
/// Behaviour:
///   - If this batch is NOT the active drying batch -> shows a "Start Drying"
///     button.
///   - Once started (or if this batch is already the active one) -> shows a
///     live countdown timer, a drying status line, and a spoilage-risk badge.
///
/// The countdown ticks every second locally. Every [_refreshInterval] the card
/// re-fetches the sensor-based drying-time and spoilage predictions and
/// re-syncs the countdown to the fresh estimate (per the 10-minute IoT
/// re-check requirement).
class DryingProcessCard extends StatefulWidget {
  final String batchId;

  const DryingProcessCard({super.key, required this.batchId});

  @override
  State<DryingProcessCard> createState() => _DryingProcessCardState();
}

class _DryingProcessCardState extends State<DryingProcessCard> {
  // Re-check the IoT sensors and re-predict every 10 minutes.
  static const Duration _refreshInterval = Duration(minutes: 10);

  Timer? _tickTimer; // per-second countdown
  Timer? _refreshTimer; // periodic sensor re-check

  bool _loading = true;
  bool _starting = false;
  String? _error; // sensor/service error (non-fatal, shown inline)

  ActiveDryingBatch? _active; // the current active batch (may be another batch)
  DryingTimeResult? _time;
  SpoilageRiskResult? _risk;

  // Remaining seconds for the live countdown, re-synced on each refresh.
  int _remainingSeconds = 0;

  // --- Prediction smoothing --------------------------------------------
  // The model re-predicts on each 10-min sensor re-check, and small sensor
  // noise makes the raw estimate wobble (e.g. 7h46m -> 8h -> 7h44m). To keep
  // the displayed time steady we:
  //   1. Average the last few raw predictions (rolling window).
  //   2. Only let the shown remaining time jump UP if the smoothed estimate
  //      rises by more than a threshold (a genuine slowdown) — otherwise it
  //      generally counts down, like a real timer.
  final List<double> _recentHours = [];
  static const int _smoothingWindow = 4;
  // Allow an upward correction only if it exceeds this (a real change, not noise).
  static const double _upwardToleranceSeconds = 30 * 60; // 30 minutes

  bool get _isThisBatchDrying =>
      _active != null && _active!.batchId == widget.batchId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      final active = await DryingService.getActiveBatch();
      if (!mounted) return;
      _active = active;
      if (_isThisBatchDrying) {
        await _refreshPredictions();
        _startTimers();
      }
    } catch (_) {
      // Service unreachable -> treat as "not drying yet"; Start will surface it.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startDrying() async {
    setState(() => _starting = true);
    try {
      final started = await DryingService.startDrying(widget.batchId);
      if (!mounted) return;
      _active = ActiveDryingBatch(
        batchId: started.batchId,
        fishType: started.fishType,
        initialWeightKg: started.initialWeightKg,
        dryingStartedAt: started.dryingStartedAt,
        elapsedDryingHours: 0,
      );
      await _refreshPredictions();
      _startTimers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_clean(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _startTimers() {
    _tickTimer?.cancel();
    _refreshTimer?.cancel();

    // Local 1-second countdown.
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });

    // Periodic sensor re-check + re-sync.
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _refreshPredictions();
    });
  }

  Future<void> _refreshPredictions() async {
    try {
      final results = await Future.wait([
        DryingService.getActiveBatch(),
        DryingService.getDryingTime(),
        DryingService.getSpoilageRisk(),
      ]);
      if (!mounted) return;
      setState(() {
        _active = results[0] as ActiveDryingBatch?;
        _time = results[1] as DryingTimeResult;
        _risk = results[2] as SpoilageRiskResult;
        _remainingSeconds = _stabilizedRemainingSeconds(
          _time!.predictedRemainingHours,
        );
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _clean(e));
    }
  }

  /// Cancel drying for this batch: confirm, call the backend stop, then reset
  /// the card back to the "Start the Drying" power-button state.
  Future<void> _cancelDrying() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cancel drying?"),
        content: const Text(
          "This stops the drying process for this batch and clears its timer. "
          "You can start drying again at any time.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Keep drying"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Cancel drying", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await DryingService.stopDrying();
      if (!mounted) return;
      _tickTimer?.cancel();
      _refreshTimer?.cancel();
      setState(() {
        _active = null;
        _time = null;
        _risk = null;
        _remainingSeconds = 0;
        _recentHours.clear();
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Drying cancelled")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_clean(e)), backgroundColor: AppColors.error),
      );
    }
  }

  /// Turn a raw model prediction (hours) into a steady remaining-seconds value
  /// for display: rolling-average smoothing + a monotonic (mostly downward)
  /// guard so the timer doesn't visibly jump around on sensor noise.
  int _stabilizedRemainingSeconds(double rawHours) {
    // 1) Rolling average of recent raw predictions.
    _recentHours.add(rawHours);
    if (_recentHours.length > _smoothingWindow) {
      _recentHours.removeAt(0);
    }
    final avgHours =
        _recentHours.reduce((a, b) => a + b) / _recentHours.length;
    final smoothedSeconds =
        (avgHours * 3600).round().clamp(0, 240 * 3600);

    // 2) Monotonic guard. On the first reading, accept it as-is. After that,
    //    prefer the lower of (current countdown, smoothed) so it keeps ticking
    //    down — only allow an upward correction beyond the tolerance.
    if (_remainingSeconds == 0 && _recentHours.length == 1) {
      return smoothedSeconds;
    }
    if (smoothedSeconds > _remainingSeconds + _upwardToleranceSeconds) {
      // Genuine slowdown — accept the higher estimate.
      return smoothedSeconds;
    }
    // Otherwise never jump up; take the smaller so it trends downward.
    return smoothedSeconds < _remainingSeconds
        ? smoothedSeconds
        : _remainingSeconds;
  }

  String _clean(Object e) => e.toString().replaceFirst("Exception: ", "").trim();

  // ---- UI -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "6. Drying Process",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (_isThisBatchDrying) _statusPill(),
            ],
          ),
          const SizedBox(height: 20),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Another batch is currently drying (only one at a time).
    if (_active != null && !_isThisBatchDrying) {
      return _infoNote(
        Icons.info_outline_rounded,
        "Another batch (${_active!.batchId}) is currently drying. "
        "Only one batch can dry at a time.",
      );
    }

    // This batch is drying -> the live dashboard.
    if (_isThisBatchDrying) return _dryingDashboard();

    // Not drying yet -> Start button.
    return _startSection();
  }

  Widget _startSection() {
    return Column(
      children: [
        const Text(
          "Start the Drying",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 18),
        // Big power button (per wireframe).
        GestureDetector(
          onTap: _starting ? null : _openStartConfirmation,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEFEFEF),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _starting
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: AppColors.error),
                    ),
                  )
                : const Icon(Icons.power_settings_new_rounded,
                    color: AppColors.error, size: 46),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _starting ? "Starting…" : "Tap to begin drying this batch",
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// Bottom-sheet checklist shown when the power button is tapped, gating the
  /// actual start on salting completion (per the wireframe).
  Future<void> _openStartConfirmation() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StartConfirmationSheet(batchId: widget.batchId),
    );
    if (confirmed == true) {
      await _startDrying();
    }
  }

  Widget _dryingDashboard() {
    return Column(
      children: [
        // Countdown timer (tap -> drying-time detail).
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DryingTimeDetailScreen()),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timelapse_rounded,
                        color: Colors.white.withValues(alpha: 0.9), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Estimated Time Remaining",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatCountdown(_remainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _time != null ? "Model: ${_time!.modelUsed}" : "",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.8), size: 16),
                    Text(
                      "Details",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Status + Spoilage badge row (spoilage tap -> detail).
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _statusTile()),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SpoilageDetailScreen()),
                  ),
                  child: _spoilageBadge(),
                ),
              ),
            ],
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 14),
          _infoNote(Icons.sensors_off_rounded,
              "Sensor update issue: $_error", warn: true),
        ],

        const SizedBox(height: 14),
        _liveFooter(),

        const SizedBox(height: 14),
        // Cancel drying.
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _cancelDrying,
            icon: const Icon(Icons.stop_circle_outlined, size: 20),
            label: const Text("Cancel Drying"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusTile() {
    final elapsed = _active?.elapsedDryingHours ?? 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                "Status",
                style: TextStyle(
                    fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Drying in progress",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            "Elapsed: ${_formatElapsed(elapsed)}",
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _spoilageBadge() {
    final risk = _risk?.spoilageRisk ?? "-";
    final s = _riskStyle(risk);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(s.icon, color: s.color, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                "Spoilage",
                style: TextStyle(
                    fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  risk.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                "Risk level",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Text(
                "Why?",
                style: TextStyle(
                    fontSize: 11, color: s.color, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.chevron_right_rounded, size: 15, color: s.color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: AppColors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text(
            "Drying",
            style: TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _liveFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sensors_rounded,
            size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          "Auto-updating from IoT sensors every 10 min",
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _infoNote(IconData icon, String text, {bool warn = false}) {
    final color = warn ? Colors.orange.shade700 : AppColors.primary;
    final bg =
        warn ? const Color(0xFFFFF8E8) : AppColors.background.withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ---- helpers ------------------------------------------------------------
  String _formatCountdown(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return "${h.toString().padLeft(2, '0')}:"
        "${m.toString().padLeft(2, '0')}:"
        "${s.toString().padLeft(2, '0')}";
  }

  String _formatElapsed(double hours) {
    final total = (hours * 3600).toInt();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    return "${h}h ${m}m";
  }

  _RiskStyle _riskStyle(String risk) {
    switch (risk.toLowerCase()) {
      case "high":
        return _RiskStyle(const Color(0xFFE53935), const Color(0xFFFFF1F0),
            Icons.gpp_bad_rounded);
      case "medium":
        return _RiskStyle(const Color(0xFFF5A623), const Color(0xFFFFF8E8),
            Icons.gpp_maybe_rounded);
      case "low":
        return _RiskStyle(const Color(0xFF2EAD4B), const Color(0xFFF1FFF3),
            Icons.verified_user_rounded);
      default:
        return _RiskStyle(
            Colors.grey, const Color(0xFFF5F5F5), Icons.help_outline_rounded);
    }
  }
}

class _RiskStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  _RiskStyle(this.color, this.bg, this.icon);
}

/// Bottom-sheet checklist gating the drying start on salting completion.
/// Checks the batch's saltingStatus; the user confirms the batch is salted and
/// placed in the oven before "Done" enables the actual start.
class _StartConfirmationSheet extends StatefulWidget {
  final String batchId;
  const _StartConfirmationSheet({required this.batchId});

  @override
  State<_StartConfirmationSheet> createState() => _StartConfirmationSheetState();
}

class _StartConfirmationSheetState extends State<_StartConfirmationSheet> {
  bool _checking = true;
  bool _saltingDone = false;
  bool _placedInOven = false; // user-acknowledged

  @override
  void initState() {
    super.initState();
    _checkSalting();
  }

  Future<void> _checkSalting() async {
    try {
      final done = await DryingService.isSaltingCompleted(widget.batchId);
      if (!mounted) return;
      setState(() {
        _saltingDone = done;
        _checking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saltingDone = false;
        _checking = false;
      });
    }
  }

  bool get _canStart => _saltingDone && _placedInOven;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Before start, make sure you have:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
          ),
          const SizedBox(height: 16),

          if (_checking)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else ...[
            // 1) Salting completed — from batch status (not user-editable).
            _checkRow(
              done: _saltingDone,
              title: "Completed salting",
              subtitle: _saltingDone
                  ? "Salting is marked complete for this batch."
                  : "This batch hasn't finished salting yet. Complete salting first.",
              locked: true,
            ),
            const SizedBox(height: 10),
            // 2) Placed in oven — user acknowledges.
            InkWell(
              onTap: () => setState(() => _placedInOven = !_placedInOven),
              borderRadius: BorderRadius.circular(14),
              child: _checkRow(
                done: _placedInOven,
                title: "Placed the batch inside the oven",
                subtitle: "Tap to confirm the batch is in the drying oven.",
                locked: false,
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canStart ? () => Navigator.pop(context, true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34C759), // green (per wireframe)
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _saltingDone ? "Done" : "Complete salting first",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow({
    required bool done,
    required String title,
    required String subtitle,
    required bool locked,
  }) {
    final color = done ? const Color(0xFF2EAD4B) : Colors.grey.shade400;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFF1FFF3) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: done ? color.withValues(alpha: 0.3) : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : (locked ? Icons.cancel_rounded : Icons.radio_button_unchecked_rounded),
            color: done ? color : (locked ? const Color(0xFFE53935) : Colors.grey.shade400),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
