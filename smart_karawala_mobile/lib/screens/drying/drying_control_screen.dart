import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';
import '../admin/admin_home_screen.dart';

class DryingControlScreen extends StatefulWidget {
  const DryingControlScreen({super.key});

  @override
  State<DryingControlScreen> createState() => _DryingControlScreenState();
}

class _DryingControlScreenState extends State<DryingControlScreen> {
  static const _refreshInterval = Duration(seconds: 5);

  SensorModel? _sensor;
  DryingSessionModel? _session;
  Timer? _sensorTimer;
  Timer? _clockTimer;

  bool _loading = true;
  bool _autoMode = true;
  bool _startSending = false;
  bool _stopSending = false;
  bool _tareSending = false;
  bool _lightSending = false;
  bool _lightOn = false;
  DateTime? _lastRefreshAt;
  String? _loadError;
  final Set<String> _shownCompletionAlerts = <String>{};

  final _temperatureController = TextEditingController(text: '40.0');
  final _humidityController = TextEditingController(text: '12.0');
  final _durationController = TextEditingController(text: '60');

  bool get _deviceReady =>
      _sensor?.online == true && (_sensor?.sensorErrors.isEmpty ?? false);

  String get _status => _session?.status ?? 'IDLE';

  bool get _dryingRunning => _status == 'DRYING' || _status == 'COOLING';

  bool get _profileReady => _status == 'READY';

  bool get _modeLocked => _dryingRunning;

  bool get _commandBusy =>
      _startSending || _stopSending || _tareSending || _lightSending;

  @override
  void initState() {
    super.initState();
    _loadSensor();
    _sensorTimer = Timer.periodic(_refreshInterval, (_) => _loadSensor());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _dryingRunning) {
        setState(() {});
      }
    });
  }

  Future<void> _loadSensor() async {
    try {
      final previousSession = _session;
      final data = await IotService.getLiveData();
      DryingSessionModel? resolvedSession = data.session;

      // Terminal sessions intentionally disappear from /iot/live. Fetch the
      // known session once more so COMPLETED, STOPPED, and FAULT remain visible.
      if (resolvedSession == null &&
          previousSession != null &&
          !previousSession.isTerminal) {
        try {
          final raw = await IotService.getDryingSession(
            previousSession.batchId,
          );
          resolvedSession = DryingSessionModel.fromJson(raw);
        } catch (_) {
          // Keep the last known session when the historical lookup is
          // temporarily unavailable.
        }
      }

      if (!mounted) return;
      final completionAlert = _completionAlertFor(
        previousSession: previousSession,
        currentSession: resolvedSession,
        sensor: data,
      );
      setState(() {
        _sensor = data;
        if (resolvedSession != null) {
          _session = resolvedSession;
          // READY is only a prepared profile. Keep the user's selected mode
          // until a drying session actually starts.
          if (resolvedSession.isRunning) {
            _autoMode = resolvedSession.mode != 'MANUAL';
          }
          _syncProfileFields(resolvedSession);
        }
        _lightOn = data.light;
        _lastRefreshAt = DateTime.now();
        _loadError = null;
        _loading = false;
      });
      if (completionAlert != null &&
          _shownCompletionAlerts.add(completionAlert.key)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showCompletionAlert(completionAlert);
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = _cleanError(error);
        _loading = false;
      });
    }
  }

  void _syncProfileFields(DryingSessionModel session) {
    if (session.targetTemperature > 0) {
      _temperatureController.text = session.targetTemperature.toStringAsFixed(
        1,
      );
    }
    if (session.targetHumidity >= 0) {
      _humidityController.text = session.targetHumidity.toStringAsFixed(1);
    }
    if (session.predictedDurationMinutes != null) {
      _durationController.text = session.predictedDurationMinutes.toString();
    }
  }

  void _changeMode(bool autoMode) {
    if (_modeLocked) {
      _showMessage(
        'Stop the current drying session before changing mode.',
        Colors.orange.shade700,
      );
      return;
    }
    setState(() => _autoMode = autoMode);
  }

  Future<void> _startDrying() async {
    if (_commandBusy || _dryingRunning) return;

    final values = _manualTargets();
    if (values == null) return;

    final readyBatchId = _session?.status == 'READY' ? _session?.batchId : null;
    final batchId =
        readyBatchId ?? 'MOBILE-${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _startSending = true);
    try {
      if (readyBatchId == null) {
        await IotService.createControlProfile(
          batchId: batchId,
          targetTemperature: values.temperature,
          targetHumidity: values.humidity,
          targetDurationMinutes: values.durationMinutes,
        );
      }

      final response = await IotService.startDryingSession(
        batchId: batchId,
        mode: _autoMode ? 'AUTO' : 'MANUAL',
      );

      if (!mounted) return;
      setState(() {
        _session = DryingSessionModel.fromJson(response);
      });
      _showMessage(
        _autoMode ? 'Automatic drying started.' : 'Manual drying started.',
        AppColors.success,
      );
      await _loadSensor();
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Could not start drying: ${_cleanError(error)}',
        AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _startSending = false);
    }
  }

  _ManualTargets? _manualTargets() {
    final temperature = double.tryParse(_temperatureController.text.trim());
    final humidity = double.tryParse(_humidityController.text.trim());
    final duration = int.tryParse(_durationController.text.trim());

    if (temperature == null ||
        temperature <= 0 ||
        temperature > 150 ||
        humidity == null ||
        humidity < 0 ||
        humidity > 100 ||
        duration == null ||
        duration <= 0 ||
        duration > 14400) {
      _showMessage(
        'Enter valid targets: 0–150°C, 0–100% humidity, and 1–14400 minutes.',
        Colors.orange.shade700,
      );
      return null;
    }
    return _ManualTargets(temperature, humidity, duration);
  }

  Future<void> _stopDrying() async {
    final session = _session;
    if (_commandBusy) {
      return;
    }
    if (session == null || session.batchId.isEmpty || session.isTerminal) {
      _showMessage('No active drying session was found.', Colors.orange);
      return;
    }

    setState(() => _stopSending = true);
    try {
      final response = await IotService.stopDryingSession(session.batchId);

      if (!mounted) return;
      setState(() {
        _session = DryingSessionModel.fromJson(response);
        _lightOn = false;
      });
      _showMessage('Drying stopped successfully.', AppColors.error);
      await _loadSensor();
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Could not stop drying: ${_cleanError(error)}',
        AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _stopSending = false);
    }
  }

  Future<void> _tareWeight() async {
    if (_tareSending) return;

    setState(() => _tareSending = true);
    try {
      await IotService.tareScale(
        batchId: _session?.isTerminal == true
            ? null
            : (_session?.batchId ?? _sensor?.batchId),
      );
      if (!mounted) return;
      _showMessage('Scale tared successfully.', AppColors.success);
      await _loadSensor();
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Could not tare the scale: ${_cleanError(error)}',
        AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _tareSending = false);
    }
  }

  Future<void> _setLight(bool enabled) async {
    final session = _session;
    if (_autoMode ||
        !_dryingRunning ||
        !_deviceReady ||
        session == null ||
        _lightSending) {
      return;
    }

    final oldValue = _lightOn;
    setState(() {
      _lightOn = enabled;
      _lightSending = true;
    });
    try {
      await IotService.setManualActuators(
        batchId: session.batchId,
        light: enabled,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _lightOn = oldValue);
      _showMessage(
        'Light command failed: ${_cleanError(error)}',
        AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _lightSending = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();

  _CompletionAlert? _completionAlertFor({
    required DryingSessionModel? previousSession,
    required DryingSessionModel? currentSession,
    required SensorModel sensor,
  }) {
    if (currentSession == null ||
        previousSession?.status == currentSession.status) {
      return null;
    }

    final hasValidLiveWeight =
        sensor.online && sensor.sensorErrors.isEmpty && sensor.weight > 0;
    final currentWeight = hasValidLiveWeight
        ? sensor.weight
        : currentSession.currentWeight;
    final targetWeight = currentSession.completionWeight;

    if (currentSession.status == 'COOLING') {
      final targetReached =
          currentWeight != null &&
          targetWeight != null &&
          currentWeight <= targetWeight;
      return _CompletionAlert(
        key: '${currentSession.batchId}:COOLING',
        icon: targetReached
            ? Icons.monitor_weight_outlined
            : Icons.timer_outlined,
        title: targetReached
            ? 'Target weight reached'
            : 'Scheduled duration reached',
        message: targetReached
            ? 'Initial ${_formatAlertWeight(currentSession.initialWeight)} • '
                  'target ${_formatAlertWeight(targetWeight)} • '
                  'current ${_formatAlertWeight(currentWeight)}. '
                  'The heater is off and the cooling fan is running.'
            : 'The heater is off and the cooling fan is running before final shutdown.',
        color: AppColors.success,
      );
    }

    if (currentSession.status == 'COMPLETED') {
      return _CompletionAlert(
        key: '${currentSession.batchId}:COMPLETED',
        icon: Icons.task_alt_rounded,
        title: 'Drying completed',
        message:
            'The cooling phase is complete. Heater, fan, and light are now off.',
        color: AppColors.primary,
      );
    }
    return null;
  }

  void _showCompletionAlert(_CompletionAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
        backgroundColor: alert.color,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(alert.icon, color: Colors.white),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAlertWeight(double? kilograms) {
    if (kilograms == null) return '—';
    if (kilograms < 1) return '${(kilograms * 1000).round()} g';
    return '${kilograms.toStringAsFixed(3)} kg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
        ),
        title: const Text(
          'Drying Control',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadSensor,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset('assets/images/logo.png', width: 52),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadSensor,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _pageIntroduction(),
                            const SizedBox(height: 16),
                            if (_loadError != null) ...[
                              _messageBanner(
                                icon: Icons.cloud_off_rounded,
                                title: 'Live update unavailable',
                                message: _loadError!,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (!_deviceReady) ...[
                              _messageBanner(
                                icon: Icons.sensors_off_rounded,
                                title: 'Drying device offline',
                                message:
                                    _sensor?.sensorErrors.isNotEmpty == true
                                    ? _sensor!.sensorErrors.join(' • ')
                                    : 'Connect the Arduino and wait for a complete sensor reading.',
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 14),
                            ],
                            _sessionHero(),
                            const SizedBox(height: 18),
                            _modeSelector(),
                            const SizedBox(height: 18),
                            if (_autoMode)
                              _autoModeContent()
                            else
                              _manualModeContent(),
                            const SizedBox(height: 18),
                            _actionCard(),
                            const SizedBox(height: 22),
                            Center(
                              child: Text(
                                'Live data refreshes every 5 seconds • Smart Karawala',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade400,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _pageIntroduction() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Oven monitoring & control',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _autoMode
                    ? 'Prediction targets and physical oven progress in one place.'
                    : 'Configure and supervise an operator-controlled drying run.',
                style: const TextStyle(
                  color: AppColors.hint,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _onlinePill(),
      ],
    );
  }

  Widget _onlinePill() {
    final online = _deviceReady;
    final color = online ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            online ? 'DEVICE ONLINE' : 'DEVICE OFFLINE',
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionHero() {
    final visual = _statusVisual(_deviceReady ? _status : 'OFFLINE');
    final session = _session;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [visual.color, visual.darkColor],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: visual.color.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(visual.icon, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visual.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusDescription(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.3,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              _heroPill(_autoMode ? 'AUTO' : 'MANUAL'),
            ],
          ),
          if (session != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OVEN SESSION',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.batchId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PROFILE SOURCE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _profileSource(session.profileSource),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _modeSelector() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.tune_rounded,
            title: 'Operation mode',
            subtitle: _modeLocked
                ? 'Mode is locked while an oven profile is active.'
                : 'Choose how this drying run will be controlled.',
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _modeButton(
                    label: 'AUTO',
                    icon: Icons.auto_mode_rounded,
                    selected: _autoMode,
                    onTap: () => _changeMode(true),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _modeButton(
                    label: 'MANUAL',
                    icon: Icons.touch_app_rounded,
                    selected: !_autoMode,
                    onTap: () => _changeMode(false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: _modeLocked ? null : onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : AppColors.hint,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _autoModeContent() {
    final session = _session;
    return Column(
      children: [
        if (session == null) _waitingForPredictionCard() else _scheduleCard(),
        const SizedBox(height: 18),
        _automaticProfileCard(),
        const SizedBox(height: 18),
        _liveConditionsCard(),
        const SizedBox(height: 18),
        _equipmentCard(manual: false),
        const SizedBox(height: 14),
        _messageBanner(
          icon: Icons.verified_user_outlined,
          title: 'Automatic safety control',
          message:
              'The controller manages the heater and exhaust fan automatically. Cooling begins when target weight or scheduled duration is reached.',
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _waitingForPredictionCard() {
    return _sectionCard(
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 31,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No active oven profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'You can start with the currently configured AUTO values, or complete Time Prediction to load batch-specific temperature and duration automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.hint, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard() {
    final session = _session!;
    final isCooling = session.status == 'COOLING';
    final total = Duration(minutes: session.predictedDurationMinutes ?? 0);
    final elapsed = _scheduledElapsed(session, total);
    final remaining = isCooling
        ? _remainingUntil(session.coolingEndsAt)
        : _scheduledRemaining(session, total);
    final progress = total.inSeconds > 0
        ? (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: isCooling ? Icons.ac_unit_rounded : Icons.timer_outlined,
            title: isCooling ? 'Cooling time remaining' : 'Oven schedule',
            subtitle: _scheduleSubtitle(session, elapsed, total),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              _formatClock(remaining),
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 40,
                height: 1,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isCooling
                  ? 'Heater off • exhaust fan cooling'
                  : _scheduleCaption(session),
              style: const TextStyle(
                color: AppColors.hint,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: session.status == 'COMPLETED'
                  ? 1
                  : (session.status == 'READY' ? 0 : progress),
              backgroundColor: AppColors.inputFill,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _automaticProfileCard() {
    final session = _session;
    final temperature =
        session?.targetTemperature ??
        double.tryParse(_temperatureController.text) ??
        0;
    final duration =
        session?.predictedDurationMinutes ??
        int.tryParse(_durationController.text);
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.auto_awesome_rounded,
            title: 'Automatic profile',
            subtitle: session == null
                ? 'Current configured AUTO values'
                : '${_profileSource(session.profileSource)} • ${session.profileVersion}',
          ),
          const SizedBox(height: 16),
          _metricGrid([
            _MetricData(
              Icons.thermostat_rounded,
              'Temperature target',
              '${temperature.toStringAsFixed(1)}°C',
              const Color(0xFFE95B4D),
            ),
            _MetricData(
              Icons.schedule_rounded,
              'Scheduled duration',
              _formatMinutes(duration),
              const Color(0xFF7A5BC7),
            ),
          ], preferredColumns: 2),
        ],
      ),
    );
  }

  Widget _manualModeContent() {
    return Column(
      children: [
        _manualCountdownCard(),
        const SizedBox(height: 18),
        _manualTargetCard(),
        const SizedBox(height: 18),
        _liveConditionsCard(),
        const SizedBox(height: 18),
        _equipmentCard(manual: true),
        const SizedBox(height: 14),
        _messageBanner(
          icon: Icons.info_outline_rounded,
          title: 'Manual target control',
          message: _dryingRunning
              ? 'Targets are locked during the run. The controller manages drying while the light remains manually switchable.'
              : 'Enter temperature and duration, tare the empty scale, place the batch, and start the run.',
          color: Colors.orange.shade700,
        ),
      ],
    );
  }

  Widget _manualCountdownCard() {
    if (_session?.mode == 'MANUAL') return _scheduleCard();

    final configuredMinutes = int.tryParse(_durationController.text.trim());
    final validDuration = configuredMinutes != null && configuredMinutes > 0;
    final preview = Duration(minutes: validDuration ? configuredMinutes : 0);

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.timer_outlined,
            title: 'Manual countdown',
            subtitle: validDuration
                ? 'Preview of the maximum manual drying time.'
                : 'Enter a valid duration to prepare the countdown.',
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              validDuration ? _formatClock(preview) : '--:--:--',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 40,
                height: 1,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Countdown starts when MANUAL drying begins',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.hint,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              15,
              30,
              60,
              120,
            ].map(_manualDurationPreset).toList(growable: false),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              minHeight: 9,
              value: 0,
              backgroundColor: AppColors.inputFill,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _manualDurationPreset(int minutes) {
    final selected = int.tryParse(_durationController.text.trim()) == minutes;
    return ChoiceChip(
      selected: selected,
      label: Text(minutes < 60 ? '$minutes min' : '${minutes ~/ 60} hr'),
      avatar: Icon(
        Icons.schedule_rounded,
        size: 16,
        color: selected ? Colors.white : AppColors.primary,
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.text,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: AppColors.inputFill,
      selectedColor: AppColors.primary,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      onSelected: _dryingRunning
          ? null
          : (_) {
              _durationController.text = minutes.toString();
              setState(() {});
            },
    );
  }

  Widget _manualTargetCard() {
    final editable = !_dryingRunning;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.edit_note_rounded,
            title: 'Operator targets',
            subtitle: editable
                ? 'These values will create a new manual oven session.'
                : 'Targets are locked while this session is active.',
          ),
          const SizedBox(height: 17),
          _targetField(
            controller: _temperatureController,
            label: 'Target temperature',
            suffix: '°C',
            icon: Icons.thermostat_rounded,
            enabled: editable,
          ),
          const SizedBox(height: 13),
          _targetField(
            controller: _durationController,
            label: 'Maximum duration',
            suffix: 'minutes',
            icon: Icons.schedule_rounded,
            enabled: editable,
            decimal: false,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _targetField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required bool enabled,
    bool decimal = true,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _liveConditionsCard() {
    final sensor = _sensor;
    final online = _deviceReady;
    final recordedWeight = online ? sensor?.weight : _session?.currentWeight;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.sensors_rounded,
            title: 'Live conditions',
            subtitle: online
                ? _freshnessText()
                : 'Showing the last recorded session value where available.',
          ),
          const SizedBox(height: 16),
          _metricGrid([
            _MetricData(
              Icons.thermostat_rounded,
              'Temperature',
              online && sensor != null
                  ? '${sensor.temperature.toStringAsFixed(1)}°C'
                  : '—',
              const Color(0xFFE95B4D),
              detail: _session == null
                  ? null
                  : 'Target ${_session!.targetTemperature.toStringAsFixed(1)}°C',
            ),
            _MetricData(
              Icons.water_drop_rounded,
              'Humidity',
              online && sensor != null
                  ? '${sensor.humidity.toStringAsFixed(1)}%'
                  : '—',
              const Color(0xFF318BD4),
            ),
            _MetricData(
              Icons.scale_rounded,
              'Batch weight',
              recordedWeight == null
                  ? '—'
                  : '${recordedWeight.toStringAsFixed(3)} kg',
              const Color(0xFF7A5BC7),
              detail: online ? 'Live scale' : 'Last recorded',
            ),
            _MetricData(
              Icons.air_rounded,
              'MQ-136 gas',
              online && sensor?.gas != null
                  ? sensor!.gas!.toStringAsFixed(0)
                  : '—',
              const Color(0xFFDD8A20),
            ),
          ], preferredColumns: 4),
        ],
      ),
    );
  }

  Widget _equipmentCard({required bool manual}) {
    final online = _deviceReady;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.electrical_services_rounded,
            title: 'Equipment',
            subtitle: manual
                ? 'Heater and fan follow targets; light can be switched manually.'
                : 'Read-only states controlled by the AUTO profile.',
          ),
          const SizedBox(height: 15),
          _actuatorTile(
            icon: Icons.local_fire_department_rounded,
            title: 'Heater',
            value: online ? _sensor?.heater : null,
            color: const Color(0xFFE95B4D),
          ),
          const SizedBox(height: 10),
          _actuatorTile(
            icon: Icons.air_rounded,
            title: 'Exhaust fan',
            value: online ? _sensor?.fan : null,
            color: const Color(0xFF318BD4),
          ),
          const SizedBox(height: 10),
          _actuatorTile(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Cabinet light',
            value: online ? _lightOn : null,
            color: const Color(0xFFDD8A20),
            trailing: manual
                ? (_lightSending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch.adaptive(
                          value: _lightOn,
                          onChanged: _dryingRunning && online
                              ? _setLight
                              : null,
                        ))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _actuatorTile({
    required IconData icon,
    required String title,
    required bool? value,
    required Color color,
    Widget? trailing,
  }) {
    final label = value == null ? 'UNKNOWN' : (value ? 'ON' : 'OFF');
    final statusColor = value == null
        ? AppColors.hint
        : (value ? AppColors.success : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null)
            trailing
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionCard() {
    final startEnabled = _deviceReady && !_startSending;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.power_settings_new_rounded,
            title: 'Session actions',
            subtitle: _actionSubtitle(),
          ),
          const SizedBox(height: 16),
          if (!_dryingRunning)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: startEnabled ? _startDrying : null,
                icon: _startSending
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        !_deviceReady
                            ? Icons.cloud_off_rounded
                            : _autoMode
                            ? Icons.auto_mode_rounded
                            : Icons.play_arrow_rounded,
                      ),
                label: Text(
                  !_deviceReady
                      ? 'DEVICE OFFLINE'
                      : _autoMode
                      ? 'START AUTO DRYING'
                      : 'START MANUAL DRYING',
                ),
                style: _primaryActionStyle(AppColors.success),
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _stopSending ? null : _stopDrying,
              icon: _stopSending
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.stop_circle_outlined),
              label: const Text('STOP DRYING'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.55),
                ),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _tareSending ? null : _tareWeight,
              icon: _tareSending
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restart_alt_rounded),
              label: const Text('TARE / RESET WEIGHT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _primaryActionStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      disabledBackgroundColor: color.withValues(alpha: 0.35),
      disabledForegroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.hint,
                  fontSize: 11.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricGrid(List<_MetricData> metrics, {int preferredColumns = 3}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth >= 720
            ? preferredColumns
            : (maxWidth >= 430 ? 2 : 1);
        const gap = 10.0;
        final itemWidth = (maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) =>
                    SizedBox(width: itemWidth, child: _metricTile(metric)),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _metricTile(_MetricData metric) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: metric.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: metric.color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(metric.icon, color: metric.color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.hint,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (metric.detail != null)
                  Text(
                    metric.detail!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: metric.color,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBanner({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.88),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusDescription() {
    final session = _session;
    if (!_deviceReady) {
      return 'Live hardware data is unavailable. Commands will still be validated by the controller.';
    }
    return switch (_status) {
      'READY' => 'Prediction profile received and ready for sensor validation.',
      'DRYING' => 'The controller is actively regulating heat and humidity.',
      'COOLING' =>
        'Heating is complete; the exhaust fan is cooling the chamber.',
      'COMPLETED' => 'This oven session completed successfully.',
      'FAULT' =>
        session?.faultReason?.isNotEmpty == true
            ? session!.faultReason!
            : 'The controller stopped this session for safety.',
      'STOPPED' => _stopReason(session?.stopReason),
      _ => 'No oven session is currently prepared or running.',
    };
  }

  String _actionSubtitle() {
    if (!_deviceReady) {
      return 'The device is offline; the controller will reject unsafe commands.';
    }
    if (_profileReady) {
      return 'A prepared profile is available for this batch.';
    }
    if (_dryingRunning) {
      return 'Stop only when operator intervention is required.';
    }
    if (_autoMode && _session == null) {
      return 'Start with the configured AUTO values or load a Time Prediction profile.';
    }
    return 'Tare the empty scale before placing a new batch.';
  }

  String _scheduleSubtitle(
    DryingSessionModel session,
    Duration elapsed,
    Duration total,
  ) {
    return switch (session.status) {
      'READY' => 'Prepared duration: ${_formatDurationWords(total)}',
      'DRYING' =>
        '${_formatDurationWords(elapsed)} elapsed of ${_formatDurationWords(total)}',
      'COOLING' => 'Safe cooling phase is now active.',
      'COMPLETED' => 'The scheduled oven session has finished.',
      'FAULT' => 'The countdown stopped because of a safety fault.',
      'STOPPED' => 'The countdown was stopped by the operator.',
      _ => 'Waiting for a drying session.',
    };
  }

  String _scheduleCaption(DryingSessionModel session) {
    return switch (session.status) {
      'READY' => 'Full scheduled duration',
      'DRYING' => 'Physical schedule remaining',
      'COMPLETED' => 'Completed',
      'FAULT' => 'Stopped by safety controller',
      'STOPPED' => 'Stopped',
      _ => 'Physical oven schedule',
    };
  }

  Duration _scheduledElapsed(DryingSessionModel session, Duration total) {
    final startedAt = session.startedAt;
    if (startedAt == null) return Duration.zero;
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed.isNegative) return Duration.zero;
    if (total.inSeconds > 0 && elapsed > total) return total;
    return elapsed;
  }

  Duration _scheduledRemaining(DryingSessionModel session, Duration total) {
    if (session.status == 'READY') return total;
    if (session.status == 'COMPLETED' ||
        session.status == 'FAULT' ||
        session.status == 'STOPPED') {
      return Duration.zero;
    }
    return _remainingUntil(session.durationEndsAt);
  }

  Duration _remainingUntil(DateTime? end) {
    if (end == null) return Duration.zero;
    final remaining = end.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String _formatClock(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 999 * 3600);
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatMinutes(int? minutes) {
    if (minutes == null || minutes <= 0) return '—';
    return _formatDurationWords(Duration(minutes: minutes));
  }

  String _formatDurationWords(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '${duration.inMinutes} min';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String _freshnessText() {
    final timestamp = _sensor?.timestamp ?? _lastRefreshAt;
    if (timestamp == null) return 'Waiting for the first sensor update.';
    final age = DateTime.now().difference(timestamp);
    if (age.inSeconds < 15) return 'Updated just now';
    if (age.inMinutes < 1) return 'Updated ${age.inSeconds}s ago';
    return 'Updated ${age.inMinutes}m ago';
  }

  String _profileSource(String source) {
    return switch (source) {
      'prediction_module' => 'Time Prediction',
      'operator_override' => 'Configured profile',
      _ => 'Configured profile',
    };
  }

  String _stopReason(String? reason) {
    return switch (reason) {
      'duration_target_reached' =>
        'The maximum scheduled duration was reached.',
      'operator_stop' => 'This session was stopped by the operator.',
      'superseded_by_new_batch' =>
        'A newer batch replaced this prepared profile.',
      'safety_fault' => 'The controller stopped this session for safety.',
      _ => 'This oven session is no longer running.',
    };
  }

  _StatusVisual _statusVisual(String status) {
    return switch (status) {
      'READY' => const _StatusVisual(
        'Profile ready',
        Icons.fact_check_outlined,
        Color(0xFF2678C8),
        Color(0xFF14578F),
      ),
      'DRYING' => const _StatusVisual(
        'Automatic drying active',
        Icons.local_fire_department_rounded,
        Color(0xFF16A36A),
        Color(0xFF08734A),
      ),
      'COOLING' => const _StatusVisual(
        'Cooling the chamber',
        Icons.ac_unit_rounded,
        Color(0xFF178FAD),
        Color(0xFF0B647A),
      ),
      'COMPLETED' => const _StatusVisual(
        'Drying completed',
        Icons.task_alt_rounded,
        Color(0xFF199C83),
        Color(0xFF096B5A),
      ),
      'STOPPED' => const _StatusVisual(
        'Drying stopped',
        Icons.stop_circle_outlined,
        Color(0xFF7B8793),
        Color(0xFF4D5861),
      ),
      'FAULT' => const _StatusVisual(
        'Safety fault',
        Icons.warning_amber_rounded,
        Color(0xFFD95555),
        Color(0xFF9B2E2E),
      ),
      'OFFLINE' => const _StatusVisual(
        'Device offline',
        Icons.sensors_off_rounded,
        Color(0xFFD95555),
        Color(0xFF9B2E2E),
      ),
      _ => const _StatusVisual(
        'Oven is idle',
        Icons.power_settings_new_rounded,
        AppColors.primary,
        AppColors.primaryDark,
      ),
    };
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _clockTimer?.cancel();
    _temperatureController.dispose();
    _humidityController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? detail;

  const _MetricData(
    this.icon,
    this.label,
    this.value,
    this.color, {
    this.detail,
  });
}

class _CompletionAlert {
  final String key;
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _CompletionAlert({
    required this.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });
}

class _StatusVisual {
  final String title;
  final IconData icon;
  final Color color;
  final Color darkColor;

  const _StatusVisual(this.title, this.icon, this.color, this.darkColor);
}

class _ManualTargets {
  final double temperature;
  final double humidity;
  final int durationMinutes;

  const _ManualTargets(this.temperature, this.humidity, this.durationMinutes);
}
