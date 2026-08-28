import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';
import '../admin/admin_home_screen.dart';
import 'alerts_screen.dart';
import 'device_status_screen.dart';
import 'drying_control_screen.dart';
import 'live_graph_screen.dart';

class DryingDashboardScreen extends StatefulWidget {
  const DryingDashboardScreen({super.key});

  @override
  State<DryingDashboardScreen> createState() => _DryingDashboardScreenState();
}

class _DryingDashboardScreenState extends State<DryingDashboardScreen> {
  static const _sensorRefreshInterval = Duration(seconds: 5);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SensorModel? _sensor;
  Timer? _sensorTimer;
  Timer? _clockTimer;
  bool _loading = true;
  bool _fetching = false;
  bool _manualRefresh = false;
  String? _loadError;
  DateTime? _lastRefreshAt;

  @override
  void initState() {
    super.initState();
    _loadSensor();
    _sensorTimer = Timer.periodic(_sensorRefreshInterval, (_) => _loadSensor());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final status = _sensor?.session?.status;
      if (mounted && (status == 'DRYING' || status == 'COOLING')) {
        setState(() {});
      }
    });
  }

  Future<void> _loadSensor({bool manual = false}) async {
    if (_fetching) return;
    _fetching = true;

    if (manual && mounted) {
      setState(() => _manualRefresh = true);
    }

    try {
      final data = await IotService.getLiveData();
      if (!mounted) return;

      setState(() {
        _sensor = data;
        _loading = false;
        _loadError = null;
        _lastRefreshAt = DateTime.now();
      });
    } catch (error) {
      debugPrint('Drying dashboard sensor error: $error');
      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadError = _sensor == null
            ? 'The drying device could not be reached.'
            : 'Live refresh failed. The last received readings are shown.';
      });
    } finally {
      _fetching = false;
      if (mounted && _manualRefresh) {
        setState(() => _manualRefresh = false);
      }
    }
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _navigationDrawer(),
      body: _loading && _sensor == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _sensor == null
          ? _emptyState()
          : _dashboardBody(_sensor!),
    );
  }

  Widget _dashboardBody(SensorModel sensor) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _loadSensor(manual: true),
        child: LayoutBuilder(
          builder: (context, viewport) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _pageHeader(sensor),
                          const SizedBox(height: 18),
                          if (_loadError != null) ...[
                            _errorBanner(),
                            const SizedBox(height: 14),
                          ],
                          _deviceBanner(sensor),
                          const SizedBox(height: 18),
                          _sessionOverview(sensor),
                          const SizedBox(height: 24),
                          _sectionHeading(
                            icon: Icons.sensors_rounded,
                            title: 'Live conditions',
                            subtitle:
                                'Readings update automatically every 5 seconds.',
                          ),
                          const SizedBox(height: 12),
                          _liveMetrics(sensor),
                          const SizedBox(height: 24),
                          _weightJourneyCard(sensor),
                          const SizedBox(height: 24),
                          _sectionHeading(
                            icon: Icons.settings_input_component_rounded,
                            title: 'Drying equipment',
                            subtitle: sensor.online
                                ? 'Current controller output state.'
                                : 'Equipment state is unavailable while offline.',
                          ),
                          const SizedBox(height: 12),
                          _equipmentGrid(sensor),
                          const SizedBox(height: 24),
                          _quickActionsCard(),
                          const SizedBox(height: 22),
                          Center(
                            child: Text(
                              _lastRefreshAt == null
                                  ? 'Waiting for the first live update'
                                  : 'Last updated ${_formatTime(_lastRefreshAt!)}  •  Smart Karawala',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.hint,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _pageHeader(SensorModel sensor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drying Dashboard',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 29,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _dashboardGreeting(sensor),
              style: const TextStyle(
                color: AppColors.hint,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

        final menuButton = _roundIconButton(
          icon: Icons.menu_rounded,
          tooltip: 'Open navigation',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
        final refreshButton = _roundIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh dashboard',
          loading: _manualRefresh,
          onPressed: _manualRefresh ? null : () => _loadSensor(manual: true),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  menuButton,
                  const SizedBox(width: 12),
                  Expanded(child: title),
                  const SizedBox(width: 8),
                  refreshButton,
                ],
              ),
              const SizedBox(height: 13),
              Row(
                children: [_onlinePill(sensor), const Spacer(), _brandButton()],
              ),
            ],
          );
        }

        return Row(
          children: [
            menuButton,
            const SizedBox(width: 14),
            Expanded(child: title),
            _onlinePill(sensor),
            const SizedBox(width: 10),
            refreshButton,
            const SizedBox(width: 10),
            _brandButton(),
          ],
        );
      },
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.7),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(icon, color: AppColors.primary, size: 23),
          ),
        ),
      ),
    );
  }

  Widget _brandButton() {
    return Tooltip(
      message: 'Back to admin home',
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        },
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            width: 48,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _onlinePill(SensorModel sensor) {
    final ready = sensor.online && sensor.sensorErrors.isEmpty;
    final color = ready ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.28)),
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
            ready ? 'DEVICE ONLINE' : 'DEVICE OFFLINE',
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _loadError!,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Try again',
            onPressed: _manualRefresh ? null : () => _loadSensor(manual: true),
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _deviceBanner(SensorModel sensor) {
    final ready = sensor.online && sensor.sensorErrors.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (ready ? AppColors.success : AppColors.error).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              ready ? Icons.sensors_rounded : Icons.sensors_off_rounded,
              color: ready ? AppColors.success : AppColors.error,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ready
                      ? 'Live monitoring active'
                      : 'Live monitoring unavailable',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ready
                      ? 'Sensor readings and controller state are current.'
                      : sensor.sensorErrors.isNotEmpty
                      ? sensor.sensorErrors.join(' • ')
                      : 'Check the IoT device connection.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.hint, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              sensor.deviceId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionOverview(SensorModel sensor) {
    final session = sensor.session;
    final status = session?.status ?? sensor.dryingStatus ?? 'IDLE';
    final mode = session?.mode ?? sensor.dryingMode ?? 'AUTO';
    final visual = _statusVisual(status);
    final schedule = _scheduleInfo(session);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: visual.gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: visual.gradient.last.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final details = _sessionDetails(
            sensor: sensor,
            session: session,
            mode: mode,
            status: status,
            visual: visual,
          );
          final countdown = _countdownPanel(
            session: session,
            mode: mode,
            schedule: schedule,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [details, const SizedBox(height: 18), countdown],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: 20),
              SizedBox(width: 330, child: countdown),
            ],
          );
        },
      ),
    );
  }

  Widget _sessionDetails({
    required SensorModel sensor,
    required DryingSessionModel? session,
    required String mode,
    required String status,
    required _StatusVisual visual,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.17),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(visual.icon, color: Colors.white, size: 28),
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
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _sessionMessage(status, mode),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 19),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _heroChip(
              icon: mode == 'MANUAL'
                  ? Icons.touch_app_rounded
                  : Icons.auto_mode_rounded,
              label: mode,
            ),
            _heroChip(icon: Icons.circle, label: status),
            if (session?.batchId.isNotEmpty == true)
              _heroChip(
                icon: Icons.inventory_2_outlined,
                label: session!.batchId,
              ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 22,
          runSpacing: 12,
          children: [
            _heroMiniMetric(
              'TEMPERATURE TARGET',
              _targetTemperatureLabel(sensor, session),
            ),
            _heroMiniMetric('MAXIMUM DURATION', _durationLabel(session)),
          ],
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => _openScreen(const DryingControlScreen()),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text('OPEN CONTROLS'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _countdownPanel({
    required DryingSessionModel? session,
    required String mode,
    required _ScheduleInfo schedule,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(schedule.icon, color: Colors.white70, size: 18),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  session == null
                      ? 'DRYING COUNTDOWN'
                      : mode == 'MANUAL'
                      ? 'MANUAL COUNTDOWN'
                      : 'AUTO COUNTDOWN',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            schedule.clock,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 35,
              height: 1,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 9),
          Text(
            schedule.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: schedule.progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            schedule.caption,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 10.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroMiniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeading({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
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

  Widget _liveMetrics(SensorModel sensor) {
    final gas = sensor.gas;
    return _responsiveGrid(
      children: [
        _metricCard(
          icon: Icons.thermostat_rounded,
          title: 'Temperature',
          value: '${sensor.temperature.toStringAsFixed(1)}°C',
          caption: sensor.targetTemperature > 0
              ? 'Target ${sensor.targetTemperature.toStringAsFixed(1)}°C'
              : 'Live chamber temperature',
          color: const Color(0xFFE95B4D),
        ),
        _metricCard(
          icon: Icons.water_drop_rounded,
          title: 'Humidity',
          value: '${sensor.humidity.toStringAsFixed(1)}%',
          caption: 'Live chamber humidity',
          color: const Color(0xFF2A9D78),
        ),
        _metricCard(
          icon: Icons.scale_rounded,
          title: 'Load cell',
          value: _formatWeight(sensor.weight),
          caption: 'Current batch weight',
          color: const Color(0xFF7656C9),
        ),
        _metricCard(
          icon: Icons.air_rounded,
          title: 'Air quality',
          value: gas == null ? '—' : gas.toStringAsFixed(0),
          caption: gas == null
              ? 'MQ136 reading unavailable'
              : 'Live MQ136 reading',
          color: const Color(0xFFDB8A22),
        ),
      ],
      desktopColumns: 4,
      compactColumns: 2,
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required String caption,
    required Color color,
  }) {
    return _surfaceCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.hint,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.hint,
              fontSize: 10.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightJourneyCard(SensorModel sensor) {
    final session = sensor.session;
    final initial = _initialWeight(sensor);
    final target = _targetWeight(sensor, initial);
    final current = _currentWeight(sensor);
    final hasCapturedWeights = initial != null && target != null;
    final progress = _weightProgress(
      initial: initial,
      target: target,
      current: current,
      fallbackPercent: sensor.progress,
    );
    final lost = initial != null && current != null
        ? (initial - current).clamp(0.0, double.infinity).toDouble()
        : null;
    final remaining = target != null && current != null
        ? (current - target).clamp(0.0, double.infinity).toDouble()
        : null;
    final targetReached =
        target != null && current != null && current <= target;

    return _surfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            icon: Icons.monitor_weight_outlined,
            title: 'Drying weight journey',
            subtitle: hasCapturedWeights
                ? 'Live load-cell progress for ${session?.batchId ?? 'the current batch'}.'
                : 'Initial weight is captured when drying starts; target weight is one-third.',
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final progressWidget = _weightProgressIndicator(
                progress: progress,
                targetReached: targetReached,
                hasCapturedWeights: hasCapturedWeights,
              );
              final valuesWidget = _weightValueGrid(
                initial: initial,
                current: current,
                target: target,
                lost: lost,
              );

              if (compact) {
                return Column(
                  children: [
                    progressWidget,
                    const SizedBox(height: 20),
                    valuesWidget,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 205, child: progressWidget),
                  const SizedBox(width: 24),
                  Expanded(child: valuesWidget),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.inputFill,
              valueColor: AlwaysStoppedAnimation<Color>(
                targetReached ? AppColors.success : const Color(0xFF7656C9),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                targetReached
                    ? Icons.check_circle_rounded
                    : hasCapturedWeights
                    ? Icons.trending_down_rounded
                    : Icons.info_outline_rounded,
                color: targetReached
                    ? AppColors.success
                    : hasCapturedWeights
                    ? const Color(0xFF7656C9)
                    : AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  targetReached
                      ? 'Target weight reached. The controller will stop heating and complete the safety cooling stage.'
                      : hasCapturedWeights
                      ? '${(progress * 100).toStringAsFixed(0)}% of the required weight reduction is complete${remaining == null ? '.' : ' • ${_formatWeight(remaining)} remains above target.'}'
                      : 'Tare the empty scale before loading. The controller will capture the positive starting weight when the session begins.',
                  style: const TextStyle(
                    color: AppColors.hint,
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weightProgressIndicator({
    required double progress,
    required bool targetReached,
    required bool hasCapturedWeights,
  }) {
    final color = targetReached ? AppColors.success : const Color(0xFF7656C9);
    return Column(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 11,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.inputFill,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      targetReached ? Icons.check_rounded : Icons.scale_rounded,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasCapturedWeights
                          ? '${(progress * 100).toStringAsFixed(0)}%'
                          : '—',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          targetReached
              ? 'Target reached'
              : hasCapturedWeights
              ? 'Weight progress'
              : 'Waiting to start',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: targetReached ? AppColors.success : AppColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _weightValueGrid({
    required double? initial,
    required double? current,
    required double? target,
    required double? lost,
  }) {
    return _responsiveGrid(
      children: [
        _weightValueTile(
          label: 'INITIAL WEIGHT',
          value: initial == null ? 'Captured at start' : _formatWeight(initial),
          icon: Icons.flag_outlined,
          color: AppColors.primary,
        ),
        _weightValueTile(
          label: 'CURRENT WEIGHT',
          value: current == null
              ? 'Waiting for sensor'
              : _formatWeight(current),
          icon: Icons.scale_rounded,
          color: const Color(0xFF7656C9),
        ),
        _weightValueTile(
          label: 'TARGET WEIGHT',
          value: target == null
              ? 'Calculated automatically'
              : _formatWeight(target),
          icon: Icons.my_location_rounded,
          color: AppColors.success,
        ),
        _weightValueTile(
          label: 'WEIGHT REDUCED',
          value: lost == null ? 'Starts at 0' : _formatWeight(lost),
          icon: Icons.south_east_rounded,
          color: const Color(0xFFDB8A22),
        ),
      ],
      desktopColumns: 2,
      compactColumns: 2,
    );
  }

  Widget _weightValueTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _equipmentGrid(SensorModel sensor) {
    final available = sensor.online && sensor.sensorErrors.isEmpty;
    return _responsiveGrid(
      children: [
        _equipmentTile(
          icon: Icons.local_fire_department_rounded,
          title: 'Heater',
          active: available ? sensor.heater : null,
          activeColor: const Color(0xFFE95B4D),
        ),
        _equipmentTile(
          icon: Icons.air_rounded,
          title: 'Exhaust fan',
          active: available ? sensor.fan : null,
          activeColor: AppColors.primary,
        ),
        _equipmentTile(
          icon: Icons.lightbulb_rounded,
          title: 'Chamber light',
          active: available ? sensor.light : null,
          activeColor: const Color(0xFFDB8A22),
        ),
      ],
      desktopColumns: 3,
    );
  }

  Widget _equipmentTile({
    required IconData icon,
    required String title,
    required bool? active,
    required Color activeColor,
  }) {
    final color = active == null
        ? AppColors.hint
        : active
        ? activeColor
        : const Color(0xFF78909C);
    final label = active == null
        ? 'UNAVAILABLE'
        : active
        ? 'ON'
        : 'OFF';

    return _surfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  active == null ? 'No live device state' : 'Controller output',
                  style: const TextStyle(color: AppColors.hint, fontSize: 10.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard() {
    return _surfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            icon: Icons.bolt_rounded,
            title: 'Quick actions',
            subtitle: 'Open another drying view without using the side menu.',
          ),
          const SizedBox(height: 17),
          _responsiveGrid(
            children: [
              _quickAction(
                icon: Icons.tune_rounded,
                label: 'Controls',
                color: AppColors.primary,
                onTap: () => _openScreen(const DryingControlScreen()),
              ),
              _quickAction(
                icon: Icons.show_chart_rounded,
                label: 'Live graph',
                color: const Color(0xFF7656C9),
                onTap: () => _openScreen(const LiveGraphScreen()),
              ),
              _quickAction(
                icon: Icons.memory_rounded,
                label: 'Device status',
                color: const Color(0xFF2A9D78),
                onTap: () => _openScreen(const DeviceStatusScreen()),
              ),
              _quickAction(
                icon: Icons.notifications_active_outlined,
                label: 'Alerts',
                color: const Color(0xFFDB8A22),
                onTap: () => _openScreen(const AlertsScreen()),
              ),
            ],
            desktopColumns: 4,
            compactColumns: 2,
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withValues(alpha: 0.13)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 19),
            ],
          ),
        ),
      ),
    );
  }

  Widget _responsiveGrid({
    required List<Widget> children,
    required int desktopColumns,
    int compactColumns = 1,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? desktopColumns
            : constraints.maxWidth >= 500
            ? compactColumns.clamp(1, children.length)
            : 1;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }

  Widget _surfaceCard({
    required Widget child,
    required EdgeInsetsGeometry padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF153A52).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Drawer _navigationDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.waves_rounded, color: Colors.white, size: 35),
                  SizedBox(height: 13),
                  Text(
                    'Smart Karawala',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'IoT Drying Module',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _drawerItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              icon: Icons.tune_rounded,
              label: 'Control',
              onTap: () => _openFromDrawer(const DryingControlScreen()),
            ),
            _drawerItem(
              icon: Icons.show_chart_rounded,
              label: 'Live Graph',
              onTap: () => _openFromDrawer(const LiveGraphScreen()),
            ),
            _drawerItem(
              icon: Icons.memory_rounded,
              label: 'Device Status',
              onTap: () => _openFromDrawer(const DeviceStatusScreen()),
            ),
            _drawerItem(
              icon: Icons.notifications_rounded,
              label: 'Alerts',
              onTap: () => _openFromDrawer(const AlertsScreen()),
            ),
            const Spacer(),
            const Divider(height: 1),
            _drawerItem(
              icon: Icons.home_outlined,
              label: 'Admin Home',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        selected: selected,
        selectedColor: AppColors.primary,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
        leading: Icon(icon, size: 22),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        onTap: onTap,
      ),
    );
  }

  Widget _emptyState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _surfaceCard(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.09),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sensors_off_rounded,
                    color: AppColors.error,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'No live drying data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _loadError ?? 'Connect the IoT service and try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.hint, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _manualRefresh
                      ? null
                      : () => _loadSensor(manual: true),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('TRY AGAIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFromDrawer(Widget screen) {
    Navigator.pop(context);
    _openScreen(screen);
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) await _loadSensor();
  }

  String _dashboardGreeting(SensorModel sensor) {
    final session = sensor.session;
    if (session?.batchId.isNotEmpty == true) {
      return 'Monitoring batch ${session!.batchId} in real time';
    }
    return 'Live oven conditions, weight progress, and equipment state';
  }

  String _sessionMessage(String status, String mode) {
    return switch (status) {
      'READY' => 'The $mode profile is prepared and ready to start.',
      'DRYING' => '$mode drying is active. Live safety rules remain enabled.',
      'COOLING' =>
        'A drying target was reached. Heating is off while the fan completes cooling.',
      'COMPLETED' => 'The drying and safety cooling stages are complete.',
      'STOPPED' => 'This drying session has been stopped.',
      'FAULT' => 'The controller stopped this session for safety.',
      _ => 'No drying session is currently prepared or running.',
    };
  }

  _StatusVisual _statusVisual(String status) {
    return switch (status) {
      'READY' => const _StatusVisual(
        title: 'Ready to dry',
        icon: Icons.task_alt_rounded,
        gradient: [Color(0xFF2879AD), Color(0xFF105179)],
      ),
      'DRYING' => const _StatusVisual(
        title: 'Drying in progress',
        icon: Icons.local_fire_department_rounded,
        gradient: [Color(0xFF168B68), Color(0xFF0B5E50)],
      ),
      'COOLING' => const _StatusVisual(
        title: 'Safety cooling',
        icon: Icons.ac_unit_rounded,
        gradient: [Color(0xFF1685A4), Color(0xFF07526D)],
      ),
      'COMPLETED' => const _StatusVisual(
        title: 'Drying completed',
        icon: Icons.verified_rounded,
        gradient: [Color(0xFF2EAD4B), Color(0xFF16732C)],
      ),
      'FAULT' => const _StatusVisual(
        title: 'Safety fault',
        icon: Icons.warning_amber_rounded,
        gradient: [Color(0xFFD95555), Color(0xFF962F2F)],
      ),
      'STOPPED' => const _StatusVisual(
        title: 'Drying stopped',
        icon: Icons.stop_circle_outlined,
        gradient: [Color(0xFFDB8A22), Color(0xFF9E5A10)],
      ),
      _ => const _StatusVisual(
        title: 'Oven available',
        icon: Icons.warehouse_outlined,
        gradient: [Color(0xFF496A82), Color(0xFF29475D)],
      ),
    };
  }

  _ScheduleInfo _scheduleInfo(DryingSessionModel? session) {
    if (session == null) {
      return const _ScheduleInfo(
        icon: Icons.timer_outlined,
        clock: '--:--:--',
        label: 'No active schedule',
        caption: 'Start a drying profile to begin the countdown.',
        progress: 0,
      );
    }

    if (session.status == 'COOLING') {
      final total = Duration(seconds: session.coolingDurationSeconds);
      final remaining = _remainingUntil(session.coolingEndsAt);
      return _ScheduleInfo(
        icon: Icons.ac_unit_rounded,
        clock: _formatClock(remaining),
        label: 'Cooling remaining',
        caption: 'Heater off • exhaust fan cooling',
        progress: _timeProgress(total: total, remaining: remaining),
      );
    }

    final total = Duration(minutes: session.predictedDurationMinutes ?? 0);
    if (session.status == 'READY') {
      return _ScheduleInfo(
        icon: Icons.schedule_rounded,
        clock: total.inSeconds > 0 ? _formatClock(total) : '--:--:--',
        label: 'Maximum drying time',
        caption: 'Countdown begins when the drying session starts.',
        progress: 0,
      );
    }

    if (session.status == 'DRYING') {
      final calculatedEnd =
          session.durationEndsAt ?? session.startedAt?.add(total);
      final remaining = _remainingUntil(calculatedEnd);
      return _ScheduleInfo(
        icon: Icons.timer_outlined,
        clock: calculatedEnd == null ? '--:--:--' : _formatClock(remaining),
        label: 'Maximum drying time remaining',
        caption: total.inMinutes > 0
            ? '${_formatDuration(total)} scheduled • weight target can finish earlier'
            : 'Weight target monitoring remains active.',
        progress: _timeProgress(total: total, remaining: remaining),
      );
    }

    if (session.status == 'COMPLETED') {
      return const _ScheduleInfo(
        icon: Icons.check_circle_rounded,
        clock: '00:00:00',
        label: 'Session completed',
        caption: 'Drying and cooling are finished.',
        progress: 1,
      );
    }

    return _ScheduleInfo(
      icon: session.status == 'FAULT'
          ? Icons.warning_amber_rounded
          : Icons.stop_circle_outlined,
      clock: '--:--:--',
      label: session.status == 'FAULT' ? 'Session fault' : 'Session stopped',
      caption: 'There is no active countdown.',
      progress: 0,
    );
  }

  double _timeProgress({required Duration total, required Duration remaining}) {
    if (total.inSeconds <= 0) return 0;
    return ((total.inSeconds - remaining.inSeconds) / total.inSeconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  Duration _remainingUntil(DateTime? end) {
    if (end == null) return Duration.zero;
    final value = end.difference(DateTime.now());
    return value.isNegative ? Duration.zero : value;
  }

  double? _initialWeight(SensorModel sensor) {
    final sessionValue = sensor.session?.initialWeight;
    if (_positiveWeight(sessionValue)) return sessionValue;
    return _positiveWeight(sensor.initialWeight) ? sensor.initialWeight : null;
  }

  double? _targetWeight(SensorModel sensor, double? initial) {
    final sessionValue = sensor.session?.completionWeight;
    if (_positiveWeight(sessionValue)) return sessionValue;
    if (_positiveWeight(sensor.targetWeight)) return sensor.targetWeight;
    return initial == null ? null : initial / 3;
  }

  double? _currentWeight(SensorModel sensor) {
    if (sensor.online &&
        sensor.sensorErrors.isEmpty &&
        sensor.weight.isFinite) {
      return sensor.weight.clamp(0.0, double.infinity).toDouble();
    }
    final sessionValue = sensor.session?.currentWeight;
    if (sessionValue != null && sessionValue.isFinite) {
      return sessionValue.clamp(0.0, double.infinity).toDouble();
    }
    return sensor.weight > 0 ? sensor.weight : null;
  }

  bool _positiveWeight(double? value) =>
      value != null && value.isFinite && value > 0;

  double _weightProgress({
    required double? initial,
    required double? target,
    required double? current,
    required double fallbackPercent,
  }) {
    if (initial != null &&
        target != null &&
        current != null &&
        initial > target) {
      return ((initial - current) / (initial - target))
          .clamp(0.0, 1.0)
          .toDouble();
    }
    if (initial != null && target != null) {
      return (fallbackPercent / 100).clamp(0.0, 1.0).toDouble();
    }
    return 0;
  }

  String _targetTemperatureLabel(
    SensorModel sensor,
    DryingSessionModel? session,
  ) {
    final value = session?.targetTemperature ?? sensor.targetTemperature;
    return value > 0 ? '${value.toStringAsFixed(1)}°C' : 'Not set';
  }

  String _durationLabel(DryingSessionModel? session) {
    final minutes = session?.predictedDurationMinutes;
    if (minutes == null || minutes <= 0) return 'Not set';
    return _formatDuration(Duration(minutes: minutes));
  }

  String _formatClock(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes <= 0) return 'Less than 1 min';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '$minutes min';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String _formatWeight(double value) {
    final safe = value.clamp(0.0, double.infinity).toDouble();
    return '${safe.toStringAsFixed(3)} kg';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class _StatusVisual {
  final String title;
  final IconData icon;
  final List<Color> gradient;

  const _StatusVisual({
    required this.title,
    required this.icon,
    required this.gradient,
  });
}

class _ScheduleInfo {
  final IconData icon;
  final String clock;
  final String label;
  final String caption;
  final double progress;

  const _ScheduleInfo({
    required this.icon,
    required this.clock,
    required this.label,
    required this.caption,
    required this.progress,
  });
}
