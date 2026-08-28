import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';
import '../../widgets/drying/live_chart.dart';

class LiveGraphScreen extends StatefulWidget {
  const LiveGraphScreen({super.key});

  @override
  State<LiveGraphScreen> createState() => _LiveGraphScreenState();
}

class _LiveGraphScreenState extends State<LiveGraphScreen> {
  static const _refreshInterval = Duration(seconds: 5);
  static const _requestTimeout = Duration(seconds: 8);
  static const _historyLimit = 30;

  Timer? _timer;
  SensorModel? _sensor;
  bool _loading = true;
  bool _fetching = false;
  bool _refreshing = false;
  String? _refreshError;
  int _selectedMetric = 0;

  final List<double> _temperatures = [];
  final List<double> _humidities = [];
  final List<double> _weights = [];

  @override
  void initState() {
    super.initState();
    _loadSensor();
    _timer = Timer.periodic(_refreshInterval, (_) => _loadSensor());
  }

  Future<void> _loadSensor({bool manual = false}) async {
    if (_fetching) return;
    _fetching = true;

    if (manual && mounted) {
      setState(() => _refreshing = true);
    }

    try {
      final data = await IotService.getLiveData().timeout(_requestTimeout);
      if (!mounted) return;

      setState(() {
        _sensor = data;
        _loading = false;
        _refreshError = null;

        if (_readingAvailable(data, const ['temperature'])) {
          _temperatures.add(data.temperature);
        }
        if (_readingAvailable(data, const ['humidity'])) {
          _humidities.add(data.humidity);
        }
        if (_readingAvailable(data, const ['weight', 'raw_weight'])) {
          _weights.add(data.weight);
        }

        _trimHistory(_temperatures);
        _trimHistory(_humidities);
        _trimHistory(_weights);
      });
    } catch (error) {
      debugPrint('Graph error: $error');
      if (!mounted) return;

      setState(() {
        _loading = false;
        _refreshError = 'Live readings could not be refreshed.';
      });
    } finally {
      _fetching = false;
      if (mounted && _refreshing) {
        setState(() => _refreshing = false);
      }
    }
  }

  bool _readingAvailable(SensorModel data, List<String> fields) {
    if (!data.online) return false;
    for (final error in data.sensorErrors) {
      final normalized = error.toLowerCase();
      if (fields.any(
        (field) => normalized.contains('missing sensor value: $field'),
      )) {
        return false;
      }
    }
    return true;
  }

  void _trimHistory(List<double> readings) {
    if (readings.length > _historyLimit) {
      readings.removeAt(0);
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: AppColors.text,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live sensor graphs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              'Drying conditions in real time',
              style: TextStyle(
                color: AppColors.hint,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _refreshing ? 'Refreshing readings' : 'Refresh now',
            onPressed: _fetching ? null : () => _loadSensor(manual: true),
            icon: _refreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _sensor == null) return const _GraphLoadingState();
    if (_sensor == null) {
      return _GraphErrorState(onRetry: () => _loadSensor(manual: true));
    }

    final sensor = _sensor!;
    final metrics = [
      _GraphMetric(
        label: 'Temperature',
        shortLabel: 'Temp',
        value: _temperatures.isEmpty ? null : _temperatures.last,
        unit: '°C',
        decimals: 1,
        color: const Color(0xFFE45757),
        icon: Icons.device_thermostat_rounded,
        values: _temperatures,
      ),
      _GraphMetric(
        label: 'Humidity',
        shortLabel: 'Humidity',
        value: _humidities.isEmpty ? null : _humidities.last,
        unit: '%',
        decimals: 1,
        color: const Color(0xFF168BD2),
        icon: Icons.water_drop_rounded,
        values: _humidities,
      ),
      _GraphMetric(
        label: 'Fish weight',
        shortLabel: 'Weight',
        value: _weights.isEmpty ? null : _weights.last,
        unit: 'kg',
        decimals: 3,
        color: const Color(0xFF7047C8),
        icon: Icons.scale_rounded,
        values: _weights,
      ),
    ];
    final selected = metrics[_selectedMetric];

    return RefreshIndicator(
      onRefresh: () => _loadSensor(manual: true),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ConnectionBanner(
                  sensor: sensor,
                  refreshError: _refreshError,
                  refreshing: _refreshing,
                  onRefresh: () => _loadSensor(manual: true),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Choose a reading',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap a card to view its recent trend.',
                  style: TextStyle(color: AppColors.hint, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _MetricPicker(
                  metrics: metrics,
                  selectedIndex: _selectedMetric,
                  onSelected: (index) =>
                      setState(() => _selectedMetric = index),
                ),
                const SizedBox(height: 16),
                LiveChart(
                  title: '${selected.label} trend',
                  values: selected.values,
                  unit: selected.unit,
                  color: selected.color,
                  icon: selected.icon,
                  decimalPlaces: selected.decimals,
                  sampleIntervalSeconds: _refreshInterval.inSeconds,
                  isLive: sensor.online && _refreshError == null,
                  allowNegative: selected.unit.contains('C'),
                ),
                const SizedBox(height: 14),
                _ReadingGuide(
                  sampleCount: selected.values.length,
                  online: sensor.online,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GraphMetric {
  final String label;
  final String shortLabel;
  final double? value;
  final String unit;
  final int decimals;
  final Color color;
  final IconData icon;
  final List<double> values;

  const _GraphMetric({
    required this.label,
    required this.shortLabel,
    required this.value,
    required this.unit,
    required this.decimals,
    required this.color,
    required this.icon,
    required this.values,
  });
}

class _MetricPicker extends StatelessWidget {
  final List<_GraphMetric> metrics;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _MetricPicker({
    required this.metrics,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: List.generate(metrics.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == metrics.length - 1 ? 0 : 10,
                ),
                child: _MetricSelector(
                  metric: metrics[index],
                  selected: index == selectedIndex,
                  horizontal: true,
                  onTap: () => onSelected(index),
                ),
              );
            }),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(metrics.length, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == metrics.length - 1 ? 0 : 12,
                ),
                child: _MetricSelector(
                  metric: metrics[index],
                  selected: index == selectedIndex,
                  onTap: () => onSelected(index),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final SensorModel sensor;
  final String? refreshError;
  final bool refreshing;
  final VoidCallback onRefresh;

  const _ConnectionBanner({
    required this.sensor,
    required this.refreshError,
    required this.refreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = refreshError != null;
    final online = sensor.online && !hasError;
    final color = hasError
        ? AppColors.error
        : online
        ? AppColors.success
        : const Color(0xFFE58A13);
    final title = hasError
        ? 'Unable to refresh'
        : online
        ? 'Live connection active'
        : 'Device is offline';
    final message = hasError
        ? 'Showing the most recent readings. Check the connection and try again.'
        : online
        ? '${sensor.deviceId} • Updated ${_formatReadingTime(sensor.timestamp)}'
        : 'Graphs show the last received values until the device reconnects.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              online ? Icons.sensors_rounded : Icons.sensors_off_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.hint,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Try again',
            onPressed: refreshing ? null : onRefresh,
            style: IconButton.styleFrom(
              foregroundColor: color,
              backgroundColor: color.withValues(alpha: 0.10),
            ),
            icon: refreshing
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: color,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _MetricSelector extends StatelessWidget {
  final _GraphMetric metric;
  final bool selected;
  final bool horizontal;
  final VoidCallback onTap;

  const _MetricSelector({
    required this.metric,
    required this.selected,
    required this.onTap,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = metric.value == null
        ? '—'
        : '${metric.value!.toStringAsFixed(metric.decimals)} ${metric.unit}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? metric.color.withValues(alpha: 0.09)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? metric.color.withValues(alpha: 0.65)
                  : AppColors.border.withValues(alpha: 0.65),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: metric.color.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: horizontal ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(metric.icon, color: metric.color, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.shortLabel,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.hint,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: selected ? metric.color : AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (horizontal) ...[
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: selected ? metric.color : AppColors.hint,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingGuide extends StatelessWidget {
  final int sampleCount;
  final bool online;

  const _ReadingGuide({required this.sampleCount, required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.touch_app_rounded,
            color: online ? AppColors.primary : AppColors.hint,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sampleCount < 2
                  ? 'Collecting readings. The trend appears after more data arrives.'
                  : 'Tap or drag across the graph to inspect an exact reading. The latest 30 readings are retained.',
              style: const TextStyle(
                color: AppColors.hint,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphLoadingState extends StatelessWidget {
  const _GraphLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 18),
            Text(
              'Connecting to the drying sensors…',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'The first live reading may take a moment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.hint, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _GraphErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.signal_wifi_connected_no_internet_4_rounded,
                    color: AppColors.error,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Live graphs are unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Check the device and network connection, then try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.hint,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
}

String _formatReadingTime(DateTime? value) {
  if (value == null) return 'just now';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}
