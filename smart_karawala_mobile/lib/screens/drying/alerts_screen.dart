import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';

enum _AlertLevel { critical, warning, healthy }

enum _AlertFilter { all, critical, warning }

class _AlertItem {
  const _AlertItem({
    required this.id,
    required this.level,
    required this.icon,
    required this.title,
    required this.message,
    required this.guidance,
    this.timestamp,
  });

  final String id;
  final _AlertLevel level;
  final IconData icon;
  final String title;
  final String message;
  final String guidance;
  final DateTime? timestamp;
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const _refreshInterval = Duration(seconds: 5);
  static const _requestTimeout = Duration(seconds: 8);
  static const _highTemperatureAlertC = 50.0;
  static const _highHumidityAlertPercent = 70.0;
  static const _highGasAlertValue = 300.0;

  SensorModel? _sensor;
  Timer? _timer;
  bool _loading = true;
  bool _fetching = false;
  bool _manualRefresh = false;
  String? _loadError;
  DateTime? _lastRefreshAt;
  _AlertFilter _filter = _AlertFilter.all;
  final Set<String> _expandedAlerts = <String>{};

  @override
  void initState() {
    super.initState();
    loadData();
    _timer = Timer.periodic(_refreshInterval, (_) => loadData());
  }

  Future<void> loadData({bool manual = false}) async {
    if (_fetching) return;
    _fetching = true;

    if (manual && mounted) {
      setState(() => _manualRefresh = true);
    }

    try {
      final data = await IotService.getLiveData().timeout(_requestTimeout);
      if (!mounted) return;

      setState(() {
        _sensor = data;
        _loading = false;
        _loadError = null;
        _lastRefreshAt = DateTime.now();
      });
    } catch (error) {
      debugPrint('Alerts refresh error: $error');
      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadError = _sensor == null
            ? 'The drying device could not be reached.'
            : 'Live refresh failed. The last received status is shown.';
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alerts & Safety',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            Text(
              'Live drying notifications',
              style: TextStyle(
                color: Color(0xFFD5ECFA),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh alerts',
            onPressed: _fetching ? null : () => loadData(manual: true),
            icon: _manualRefresh
                ? const SizedBox.square(
                    dimension: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading && _sensor == null
          ? _loadingState()
          : _sensor == null
          ? _unavailableState()
          : _alertsBody(_sensor!),
    );
  }

  Widget _loadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Checking live safety status…',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Connecting to the drying device',
            style: TextStyle(color: AppColors.hint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _unavailableState() {
    return LayoutBuilder(
      builder: (context, viewport) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => loadData(manual: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF153A52,
                            ).withOpacity(0.08),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_off_rounded,
                              size: 32,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Alerts are unavailable',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _loadError ??
                                'No live safety data has been received yet.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.hint,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _fetching
                                  ? null
                                  : () => loadData(manual: true),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try again'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Pull down or tap Try again to reconnect.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.hint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _alertsBody(SensorModel sensor) {
    final alerts = _buildAlerts(sensor);
    final criticalCount = alerts
        .where((alert) => alert.level == _AlertLevel.critical)
        .length;
    final warningCount = alerts
        .where((alert) => alert.level == _AlertLevel.warning)
        .length;
    final activeCount = criticalCount + warningCount;
    final visibleAlerts = alerts.where(_matchesFilter).toList(growable: false);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => loadData(manual: true),
      child: LayoutBuilder(
        builder: (context, viewport) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryCard(
                          sensor: sensor,
                          activeCount: activeCount,
                          criticalCount: criticalCount,
                          warningCount: warningCount,
                        ),
                        if (_loadError != null) ...[
                          const SizedBox(height: 14),
                          _refreshErrorBanner(),
                        ],
                        const SizedBox(height: 24),
                        _sectionHeader(activeCount),
                        const SizedBox(height: 12),
                        _filterBar(
                          allCount: alerts.length,
                          criticalCount: criticalCount,
                          warningCount: warningCount,
                        ),
                        const SizedBox(height: 16),
                        if (visibleAlerts.isEmpty)
                          _filteredEmptyState()
                        else
                          _alertGrid(visibleAlerts),
                        const SizedBox(height: 24),
                        _updateFooter(sensor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<_AlertItem> _buildAlerts(SensorModel sensor) {
    final readingTime = sensor.timestamp ?? _lastRefreshAt;

    if (!sensor.online) {
      return [
        _AlertItem(
          id: 'device-offline',
          level: _AlertLevel.critical,
          icon: Icons.portable_wifi_off_rounded,
          title: 'Drying device is offline',
          message:
              'Live readings and equipment states are currently unavailable.',
          guidance:
              'Check the Arduino power, USB/serial connection, and monitoring service before starting or controlling drying.',
          timestamp: readingTime,
        ),
      ];
    }

    final alerts = <_AlertItem>[];

    if (sensor.dryingStatus == 'FAULT') {
      alerts.add(
        _AlertItem(
          id: 'drying-fault',
          level: _AlertLevel.critical,
          icon: Icons.gpp_bad_rounded,
          title: 'Drying session fault',
          message: sensor.session?.faultReason?.trim().isNotEmpty == true
              ? sensor.session!.faultReason!.trim()
              : 'The controller stopped the active drying session for safety.',
          guidance:
              'Inspect the device and sensor readings. Resolve the cause before starting another session.',
          timestamp: sensor.session?.updatedAt ?? readingTime,
        ),
      );
    }

    // Keep the existing alert thresholds unchanged.
    if (sensor.temperature > _highTemperatureAlertC) {
      alerts.add(
        _AlertItem(
          id: 'high-temperature',
          level: _AlertLevel.critical,
          icon: Icons.device_thermostat_rounded,
          title: 'High temperature',
          message:
              'Current temperature is ${sensor.temperature.toStringAsFixed(1)} °C, above the ${_highTemperatureAlertC.toStringAsFixed(1)} °C alert level.',
          guidance:
              'Monitor the heater and airflow. Stop the process if the temperature continues to rise unexpectedly.',
          timestamp: readingTime,
        ),
      );
    }

    if (sensor.humidity > _highHumidityAlertPercent) {
      alerts.add(
        _AlertItem(
          id: 'high-humidity',
          level: _AlertLevel.warning,
          icon: Icons.water_drop_rounded,
          title: 'High humidity',
          message:
              'Current humidity is ${sensor.humidity.toStringAsFixed(1)}%, above the ${_highHumidityAlertPercent.toStringAsFixed(1)}% alert level.',
          guidance:
              'Check ventilation and airflow. High humidity can slow the drying process.',
          timestamp: readingTime,
        ),
      );
    }

    final gasAlertValue = sensor.targetGas ?? _highGasAlertValue;
    if (sensor.gas != null && sensor.gas! > gasAlertValue) {
      alerts.add(
        _AlertItem(
          id: 'gas-warning',
          level: _AlertLevel.warning,
          icon: Icons.air_rounded,
          title: 'Gas level warning',
          message:
              'Current gas reading is ${sensor.gas!.toStringAsFixed(0)}; the configured limit is ${gasAlertValue.toStringAsFixed(0)}.',
          guidance:
              'Improve ventilation and inspect the fish and chamber before continuing unattended operation.',
          timestamp: readingTime,
        ),
      );
    }

    if (sensor.sensorErrors.isNotEmpty) {
      final readableErrors = sensor.sensorErrors
          .take(3)
          .map(_humanizeSensorError)
          .join(', ');
      final remaining = sensor.sensorErrors.length - 3;

      alerts.add(
        _AlertItem(
          id: 'sensor-errors',
          level: _AlertLevel.warning,
          icon: Icons.sensors_off_rounded,
          title: 'Sensor readings need attention',
          message:
              '$readableErrors${remaining > 0 ? ' and $remaining more' : ''}.',
          guidance:
              'Check the affected sensor wiring and allow readings to stabilize before relying on automatic control.',
          timestamp: readingTime,
        ),
      );
    }

    if (alerts.isEmpty) {
      alerts.add(
        _AlertItem(
          id: 'system-normal',
          level: _AlertLevel.healthy,
          icon: Icons.verified_rounded,
          title: 'System operating normally',
          message:
              'No active safety alerts were detected in the latest reading.',
          guidance:
              'This page refreshes automatically every five seconds. No action is needed.',
          timestamp: readingTime,
        ),
      );
    }

    return alerts;
  }

  Widget _summaryCard({
    required SensorModel sensor,
    required int activeCount,
    required int criticalCount,
    required int warningCount,
  }) {
    final offline = !sensor.online;
    final hasCritical = criticalCount > 0;
    final hasWarning = warningCount > 0;
    final Color startColor;
    final Color endColor;
    final IconData icon;
    final String title;
    final String subtitle;

    if (_loadError != null) {
      startColor = const Color(0xFF9A5B08);
      endColor = const Color(0xFFE49A28);
      icon = Icons.cloud_off_rounded;
      title = 'Live alert status unavailable';
      subtitle =
          'Showing the last received device status. Refresh to reconnect.';
    } else if (offline) {
      startColor = const Color(0xFFB3261E);
      endColor = const Color(0xFFE15C4F);
      icon = Icons.wifi_off_rounded;
      title = 'Device connection lost';
      subtitle = 'Reconnect the device to resume live safety monitoring.';
    } else if (hasCritical) {
      startColor = const Color(0xFFB3261E);
      endColor = const Color(0xFFE8683A);
      icon = Icons.crisis_alert_rounded;
      title =
          '$criticalCount critical ${criticalCount == 1 ? 'alert' : 'alerts'}';
      subtitle = 'Immediate attention is recommended.';
    } else if (hasWarning) {
      startColor = const Color(0xFFB75B08);
      endColor = const Color(0xFFE89A22);
      icon = Icons.warning_amber_rounded;
      title =
          '$warningCount active ${warningCount == 1 ? 'warning' : 'warnings'}';
      subtitle = 'Review the latest readings and guidance below.';
    } else {
      startColor = const Color(0xFF087A5B);
      endColor = const Color(0xFF24A56E);
      icon = Icons.health_and_safety_rounded;
      title = 'All systems normal';
      subtitle = 'No active safety alerts in the latest reading.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final status = Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.17),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.22),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 29),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final connection = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${sensor.deviceId}  •  ${sensor.online ? 'ONLINE' : 'OFFLINE'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
              ],
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                status,
                const SizedBox(height: 16),
                connection,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: status),
                    const SizedBox(width: 20),
                    connection,
                  ],
                ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _summaryPill(
                    label: activeCount == 0
                        ? 'No active alerts'
                        : '$activeCount active',
                    icon: activeCount == 0
                        ? Icons.check_circle_outline_rounded
                        : Icons.notifications_active_outlined,
                  ),
                  _summaryPill(
                    label: 'Auto-refresh: 5 sec',
                    icon: Icons.sync_rounded,
                  ),
                  if (sensor.dryingStatus != null)
                    _summaryPill(
                      label: sensor.dryingStatus!,
                      icon: Icons.local_fire_department_outlined,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryPill({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _refreshErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE69A2D).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_problem_rounded, color: Color(0xFFB75B08)),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _loadError!,
              style: const TextStyle(
                color: Color(0xFF74420D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          TextButton(
            onPressed: _fetching ? null : () => loadData(manual: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(int activeCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current notifications',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                activeCount == 0
                    ? 'Latest reading is clear. Tap a card for more information.'
                    : 'Live conditions only. Tap an alert to view recommended action.',
                style: const TextStyle(
                  color: AppColors.hint,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterBar({
    required int allCount,
    required int criticalCount,
    required int warningCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(
            filter: _AlertFilter.all,
            label: 'All',
            count: allCount,
            icon: Icons.view_list_rounded,
          ),
          const SizedBox(width: 8),
          _filterChip(
            filter: _AlertFilter.critical,
            label: 'Critical',
            count: criticalCount,
            icon: Icons.error_outline_rounded,
          ),
          const SizedBox(width: 8),
          _filterChip(
            filter: _AlertFilter.warning,
            label: 'Warnings',
            count: warningCount,
            icon: Icons.warning_amber_rounded,
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required _AlertFilter filter,
    required String label,
    required int count,
    required IconData icon,
  }) {
    final selected = _filter == filter;
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 17,
        color: selected ? Colors.white : AppColors.primary,
      ),
      label: Text('$label  $count'),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.text,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      onSelected: (_) => setState(() => _filter = filter),
    );
  }

  Widget _alertGrid(List<_AlertItem> alerts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 720 && alerts.length > 1;
        final cardWidth = twoColumns
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final alert in alerts)
              SizedBox(width: cardWidth, child: _alertCard(alert)),
          ],
        );
      },
    );
  }

  Widget _alertCard(_AlertItem alert) {
    final visual = _visualFor(alert.level);
    final expanded = _expandedAlerts.contains(alert.id);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () {
          setState(() {
            if (expanded) {
              _expandedAlerts.remove(alert.id);
            } else {
              _expandedAlerts.add(alert.id);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: visual.color.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF153A52).withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: visual.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(alert.icon, color: visual.color, size: 25),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: visual.color.withOpacity(0.09),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                visual.label,
                                style: TextStyle(
                                  color: visual.color,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.65,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              expanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppColors.hint,
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          alert.title,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                alert.message,
                style: const TextStyle(
                  color: Color(0xFF526A7C),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: AppColors.hint,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _formatTimestamp(alert.timestamp),
                      style: const TextStyle(
                        color: AppColors.hint,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    expanded ? 'Hide guidance' : 'View guidance',
                    style: TextStyle(
                      color: visual.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 180),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: visual.color.withOpacity(0.055),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          color: visual.color,
                          size: 18,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recommended action',
                                style: TextStyle(
                                  color: visual.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                alert.guidance,
                                style: const TextStyle(
                                  color: Color(0xFF526A7C),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filteredEmptyState() {
    final label = _filter == _AlertFilter.critical
        ? 'critical alerts'
        : 'warnings';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.09),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 28,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            'No $label right now',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Choose All to view the current system status.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.hint, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _updateFooter(SensorModel sensor) {
    final timestamp = sensor.timestamp ?? _lastRefreshAt;
    return Center(
      child: Column(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.hint, size: 18),
          const SizedBox(height: 6),
          Text(
            'Latest device reading: ${_formatTimestamp(timestamp)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.hint,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Smart Karawala safety monitoring',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.hint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(_AlertItem alert) {
    switch (_filter) {
      case _AlertFilter.all:
        return true;
      case _AlertFilter.critical:
        return alert.level == _AlertLevel.critical;
      case _AlertFilter.warning:
        return alert.level == _AlertLevel.warning;
    }
  }

  ({Color color, String label}) _visualFor(_AlertLevel level) {
    switch (level) {
      case _AlertLevel.critical:
        return (color: const Color(0xFFD33A2C), label: 'CRITICAL');
      case _AlertLevel.warning:
        return (color: const Color(0xFFD97706), label: 'WARNING');
      case _AlertLevel.healthy:
        return (color: const Color(0xFF168765), label: 'HEALTHY');
    }
  }

  String _humanizeSensorError(String error) {
    final normalized = error.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    if (normalized.isEmpty) return 'Unknown sensor issue';
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Time unavailable';

    final local = timestamp.toLocal();
    final now = DateTime.now();
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final time =
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}:${_twoDigits(local.second)}';

    if (sameDay) return 'Today at $time';
    return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year} at $time';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
