import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/drying_model.dart';
import '../../services/Drying/drying_service.dart';
import '../../services/Drying/spoilage_detail_screen.dart';
import '../../services/Drying/drying_time_detail_screen.dart';
import '../../services/iot_service.dart';

/// How often the drying card re-fetches live IoT sensor data and re-predicts
/// drying time / spoilage risk. Change this single value to adjust the
/// polling rate app-wide.
const Duration kDryingSensorRefreshInterval = Duration(seconds: 10);

/// TEMPORARY (testing): duration used when resuming a paused batch, matching
/// the override on the Time Prediction screen. Set to null to fall back to the
/// batch's remaining predicted time.
const int _resumeDurationMinutes = 10;

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
  Timer? _tickTimer; // per-second countdown
  Timer? _refreshTimer; // periodic sensor re-check

  bool _loading = true;
  bool _starting = false;
  String? _error; // sensor/service error (non-fatal, shown inline)

  ActiveDryingBatch? _active; // the current active batch (may be another batch)
  DryingTimeResult? _time;
  SpoilageRiskResult? _risk;
  OverDryingRiskResult? _overDryingRisk;

  // --- Paused state ------------------------------------------------------
  // The oven has no real pause: STOPPED is terminal and a stopped session
  // cannot be restarted. So "pause" stops the oven and remembers the batch's
  // settings here, and "resume" starts a FRESH session from them.
  bool _paused = false;
  bool _resuming = false;
  double? _pausedTemperatureC;
  double? _pausedTotalHours;

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

  /// True once the oven itself reports the batch fully dried (its target
  /// weight was reached and cooling finished) - not when the local countdown
  /// merely reaches zero. The countdown is only an estimate and can hit
  /// 00:00:00 while the oven is still genuinely drying, so ovenStatus is the
  /// ground truth here, the same way _ovenMismatchBanner() treats it.
  bool get _isComplete => _active?.ovenStatus == "COMPLETED";

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
      // This path has no predicted temperature/duration to build a control
      // profile from, so it can only start the oven if a profile already
      // exists for this batch (created by the Time Prediction flow).
      // Without one the oven has no set-points and must not be started.
      await IotService.startDryingSession(
        batchId: widget.batchId,
        mode: 'AUTO',
      );

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

    // Local 1-second countdown. Only ticks while the oven is actually
    // running - otherwise the timer would keep counting down after the oven
    // has stopped or faulted, which misrepresents the batch as still drying.
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_active?.ovenRunning == false) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });

    // Periodic sensor re-check + re-sync.
    _refreshTimer = Timer.periodic(kDryingSensorRefreshInterval, (_) {
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

    // Separate call, separate failure handling: the over-drying check also
    // performs the safety stop on the backend when risk is HIGH, so it must
    // keep being polled on its own schedule even if the block above fails,
    // and a failure here must never block the time/spoilage display above.
    if (!_isThisBatchDrying) return;
    try {
      final risk = await DryingService.getOverDryingRisk();
      if (!mounted) return;
      setState(() => _overDryingRisk = risk);
    } catch (_) {
      // Advisory only - the safety stop itself already happened server-side
      // if conditions warranted it; a failed poll here just means this
      // particular refresh didn't get to check again yet.
    }
  }

  /// Cancel drying for this batch: confirm, call the backend stop, then reset
  /// the card back to the "Start the Drying" power-button state.
  Future<void> _cancelDrying() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Pause drying?"),
        content: const Text(
          "This switches the oven off and pauses this batch. You can resume "
          "it from here, which starts a fresh drying run with the same "
          "settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Keep drying"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Pause drying", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Remember the settings so Resume can recreate an equivalent session.
    final pausedTemp = _active?.initialTemperatureC;
    final pausedHours = _active?.initialTotalHours;

    try {
      // Stop the physical oven first so the heater/fan are actually switched
      // off, then clear the prediction service's active-batch pointer. If the
      // oven has no session for this batch (e.g. drying was started outside
      // the app) that's not fatal - still clear the pointer below.
      try {
        // Stop the session the oven actually opened, which may run under a
        // different id than the batch (see ActiveDryingBatch.ovenSessionId).
        await IotService.stopDryingSession(
          _active?.ovenSessionId ?? widget.batchId,
        );
      } catch (e) {
        debugPrint("Oven stop failed (continuing to clear active batch): $e");
      }

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
        _paused = true;
        _pausedTemperatureC = pausedTemp;
        _pausedTotalHours = pausedHours;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Drying paused")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_clean(e)), backgroundColor: AppColors.error),
      );
    }
  }

  /// Resume a paused batch.
  ///
  /// The oven cannot restart a STOPPED session, so this starts a FRESH run
  /// using the settings captured when the batch was paused. Elapsed drying
  /// time from the previous run is not carried over.
  Future<void> _resumeDrying() async {
    setState(() => _resuming = true);
    try {
      // A stopped session still occupies the batch id, so creating a new
      // profile may 409. Try, and fall through to start either way.
      try {
        await IotService.createControlProfile(
          batchId: widget.batchId,
          targetTemperature: _pausedTemperatureC ?? 50.0,
          targetHumidity: 55.0,
          targetDurationMinutes: _resumeDurationMinutes,
        );
      } catch (e) {
        debugPrint("Resume: profile not recreated (likely exists): $e");
      }

      await IotService.startDryingSession(
        batchId: widget.batchId,
        mode: 'AUTO',
      );

      await DryingService.startDrying(
        widget.batchId,
        initialTemperatureC: _pausedTemperatureC,
        initialTotalHours: _pausedTotalHours,
      );

      if (!mounted) return;
      setState(() {
        _paused = false;
        _error = null;
      });
      await _refreshPredictions();
      _startTimers();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Drying resumed")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_clean(e)), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _resuming = false);
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
            color: AppColors.primary.withOpacity(0.04),
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

    // Paused -> offer Resume.
    if (_paused) return _pausedSection();

    // Not drying yet -> Start button.
    return _startSection();
  }

  Widget _pausedSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.pause_circle_filled_rounded,
                  color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Drying paused",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "The oven is switched off. Resuming starts a fresh "
                      "drying run with the same settings.",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _resuming ? null : _resumeDrying,
            icon: _resuming
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(_resuming ? "Resuming…" : "Resume Drying"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
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
                  color: AppColors.error.withOpacity(0.15),
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

  /// Shown when our records say this batch is drying but the oven says
  /// otherwise (stopped, faulted, or unreachable). Without this the countdown
  /// silently keeps running against a switched-off oven.
  Widget? _ovenMismatchBanner() {
    final a = _active;
    if (a == null || a.ovenRunning) return null;

    final String message;
    if (!a.ovenReachable) {
      message = "Can't reach the drying oven. The countdown is paused until "
          "it responds again.";
    } else if (a.ovenStoppedReason != null && a.ovenStoppedReason!.isNotEmpty) {
      message = "The oven stopped drying (${a.ovenStatus ?? 'stopped'}): "
          "${a.ovenStoppedReason}. The countdown is paused.";
    } else {
      message = "The oven is not drying (${a.ovenStatus ?? 'stopped'}). "
          "The countdown is paused.";
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5C2C2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8B2F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// True once our own over-drying check is the reason the oven isn't
  /// running - the generic oven-mismatch banner below always shows
  /// "operator_stop" for any stop (Milan's /stop endpoint takes no reason),
  /// which would misrepresent a genuine safety stop as a person pausing it.
  bool get _stoppedByOverDrying =>
      _overDryingRisk?.ovenStopped == true &&
      _active != null &&
      !_active!.ovenRunning;

  /// Shown once, right after the backend reports it auto-stopped the oven
  /// for over-drying/burn risk. Takes priority over the generic
  /// _ovenMismatchBanner() so the operator sees the real reason instead of
  /// the misleading "operator_stop" Milan's service always records (its
  /// /stop endpoint has no reason parameter to carry ours through).
  Widget? _autoStopBanner() {
    if (!_stoppedByOverDrying) return null;
    final risk = _overDryingRisk!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE53935).withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: Color(0xFFE53935), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Oven stopped automatically: over-drying risk",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B2F2F),
                  ),
                ),
                if (risk.reasons.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    risk.reasons.first,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF8B2F2F)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Over-drying / burn-risk panel: Low/Medium/High badge, why it's flagged,
  /// and the plain-language LLM note when one exists (High risk only - see
  /// llm_reasoning_service's cost guards on the backend).
  Widget? _overDryingPanel() {
    final risk = _overDryingRisk;
    // Nothing worth a panel for: no data yet, or a clean Low reading with no
    // reasons to show (the common case - most of a drying run).
    if (risk == null) return null;
    if (risk.overDryingRisk.toLowerCase() == "low" && risk.reasons.isEmpty) {
      return null;
    }

    final s = _riskStyle(risk.overDryingRisk);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(s.icon, color: s.color, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                "Over-drying / burn risk",
                style: TextStyle(
                    fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  risk.overDryingRisk.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (risk.reasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...risk.reasons.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  r,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade800),
                ),
              ),
            ),
          ],
          if (risk.explanation != null && risk.explanation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 14, color: s.color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      risk.explanation!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dryingDashboard() {
    // The auto-stop banner already explains why the oven isn't running when
    // over-drying was the cause, so suppress the generic mismatch banner in
    // that case rather than show both.
    final mismatch = _stoppedByOverDrying ? null : _ovenMismatchBanner();
    return Column(
      children: [
        if (mismatch != null) mismatch,
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
                        color: Colors.white.withOpacity(0.9), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Estimated Time Remaining",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
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
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.white.withOpacity(0.8), size: 16),
                    Text(
                      "Details",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
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

        if (_autoStopBanner() != null) ...[
          const SizedBox(height: 14),
          _autoStopBanner()!,
        ],

        if (_overDryingPanel() != null) ...[
          const SizedBox(height: 14),
          _overDryingPanel()!,
        ],

        if (_error != null) ...[
          const SizedBox(height: 14),
          _infoNote(Icons.sensors_off_rounded,
              "Sensor update issue: $_error", warn: true),
        ],

        const SizedBox(height: 14),
        _liveFooter(),

        const SizedBox(height: 14),
        // Cancel drying, or a disabled "complete" indicator once the oven
        // itself reports the batch fully dried - there is nothing left to
        // pause at that point.
        SizedBox(
          width: double.infinity,
          child: _isComplete
              ? OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text("Drying Complete"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    disabledForegroundColor: AppColors.success,
                    side: BorderSide(color: AppColors.success.withOpacity(0.5)),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: _cancelDrying,
                  icon: const Icon(Icons.stop_circle_outlined, size: 20),
                  label: const Text("Pause Drying"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.5)),
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
                  color: AppColors.primary.withOpacity(0.1),
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
          Text(
            _isComplete ? "Drying complete" : "Drying in progress",
            style: const TextStyle(
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
        border: Border.all(color: s.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.15),
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
        color: AppColors.success.withOpacity(0.12),
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
          "Auto-updating from IoT sensors every ${_formatInterval(kDryingSensorRefreshInterval)}",
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _infoNote(IconData icon, String text, {bool warn = false}) {
    final color = warn ? Colors.orange.shade700 : AppColors.primary;
    final bg =
        warn ? const Color(0xFFFFF8E8) : AppColors.background.withOpacity(0.5);
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

  String _formatInterval(Duration d) {
    if (d.inMinutes >= 1 && d.inSeconds % 60 == 0) {
      final m = d.inMinutes;
      return "$m min${m == 1 ? '' : 's'}";
    }
    final s = d.inSeconds;
    return "$s sec${s == 1 ? '' : 's'}";
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
        border: Border.all(color: done ? color.withOpacity(0.3) : Colors.grey.shade200),
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
