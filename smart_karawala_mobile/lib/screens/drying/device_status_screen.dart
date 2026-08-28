import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';

class DeviceStatusScreen extends StatefulWidget {
  const DeviceStatusScreen({super.key});

  @override
  State<DeviceStatusScreen> createState() => _DeviceStatusScreenState();
}

class _DeviceStatusScreenState extends State<DeviceStatusScreen> {
  static const _requestTimeout = Duration(seconds: 8);

  SensorModel? sensor;

  bool loading = true;

  bool _fetching = false;

  bool _manualRefresh = false;

  String? _loadError;

  DateTime? _lastUpdatedAt;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    loadData();

    timer = Timer.periodic(const Duration(seconds: 5), (_) => loadData());
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
        sensor = data;
        loading = false;
        _loadError = null;
        _lastUpdatedAt = data.timestamp ?? DateTime.now();
      });
    } catch (e) {
      debugPrint("Device status error: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
        _loadError = sensor == null
            ? 'The device service could not be reached.'
            : 'Live refresh failed. Readings are hidden until the connection is restored.';
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
    timer?.cancel();
    super.dispose();
  }

  Widget statusTile({
    required IconData icon,
    required String title,
    required bool? status,
    required Color activeColor,
  }) {
    final color = status == null
        ? AppColors.hint
        : status
        ? activeColor
        : const Color(0xFF78909C);
    final label = status == null
        ? 'UNAVAILABLE'
        : status
        ? 'ON'
        : 'OFF';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD5E8F3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status == null
                      ? 'No live device state'
                      : 'Arduino reported output',
                  style: const TextStyle(color: AppColors.hint, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.18)),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveOnline = sensor?.online == true && _loadError == null;
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Device Status',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            tooltip: 'Refresh device status',
            onPressed: _fetching ? null : () => loadData(manual: true),
            icon: _manualRefresh
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: loading
          ? _loadingState()
          : sensor == null
          ? _emptyState()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => loadData(manual: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _pageHeader(sensor!),

                        if (_loadError != null) ...[
                          const SizedBox(height: 14),
                          _errorBanner(),
                        ],

                        const SizedBox(height: 18),

                        // DEVICE
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                            side: BorderSide(
                              color:
                                  (liveOnline
                                          ? AppColors.success
                                          : _loadError != null
                                          ? const Color(0xFFE99722)
                                          : AppColors.error)
                                      .withOpacity(0.28),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: liveOnline
                                    ? AppColors.success.withOpacity(.12)
                                    : (_loadError != null
                                              ? const Color(0xFFE99722)
                                              : AppColors.error)
                                          .withOpacity(.12),
                                child: Icon(
                                  liveOnline
                                      ? Icons.developer_board_rounded
                                      : _loadError != null
                                      ? Icons.cloud_off_rounded
                                      : Icons.portable_wifi_off_rounded,
                                  color: liveOnline
                                      ? AppColors.success
                                      : _loadError != null
                                      ? const Color(0xFFE99722)
                                      : AppColors.error,
                                ),
                              ),
                              title: Text(
                                sensor!.deviceId,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              subtitle: Text(
                                liveOnline
                                    ? 'Arduino connected • Live monitoring active'
                                    : _loadError != null
                                    ? 'Connection status is stale • Refresh to reconnect'
                                    : 'Arduino disconnected • Check power and cable',
                                style: const TextStyle(
                                  color: AppColors.hint,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: liveOnline
                                      ? AppColors.success
                                      : _loadError != null
                                      ? const Color(0xFFE99722)
                                      : AppColors.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  liveOnline
                                      ? 'ONLINE'
                                      : _loadError != null
                                      ? 'STALE'
                                      : 'OFFLINE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (liveOnline && sensor!.sensorErrors.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _sensorIssueBanner(sensor!.sensorErrors),
                        ],

                        const SizedBox(height: 20),

                        // DEVICE CONTROLS STATUS
                        _sectionHeader(
                          icon: Icons.settings_input_component_rounded,
                          title: 'Controller outputs',
                          subtitle: liveOnline
                              ? 'Actual states reported by the Arduino.'
                              : 'Output states are unavailable without a fresh connection.',
                        ),

                        const SizedBox(height: 12),

                        _actuatorGrid(sensor!),

                        const SizedBox(height: 20),

                        _sectionHeader(
                          icon: Icons.monitor_heart_outlined,
                          title: 'Live sensor readings',
                          subtitle: liveOnline
                              ? 'Automatically updated every 5 seconds.'
                              : 'Values are hidden until live monitoring resumes.',
                        ),

                        const SizedBox(height: 12),

                        // SENSOR VALUES
                        if (!liveOnline)
                          _readingsUnavailableCard()
                        else
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                              side: const BorderSide(color: Color(0xFFD5E8F3)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.thermostat,
                                    color: Colors.red,
                                  ),
                                  title: const Text("Temperature"),
                                  trailing: Text(
                                    _readingText(
                                      sensor!,
                                      field: 'temperature',
                                      value:
                                          '${sensor!.temperature.toStringAsFixed(1)}°C',
                                      invalidAlias: 'sht temp',
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  leading: const Icon(
                                    Icons.water_drop,
                                    color: Colors.blue,
                                  ),
                                  title: const Text("Humidity"),
                                  trailing: Text(
                                    _readingText(
                                      sensor!,
                                      field: 'humidity',
                                      value:
                                          '${sensor!.humidity.toStringAsFixed(1)}%',
                                      invalidAlias: 'humidity',
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  leading: const Icon(
                                    Icons.scale,
                                    color: Colors.deepPurple,
                                  ),
                                  title: const Text("Current Weight"),
                                  trailing: Text(
                                    _readingText(
                                      sensor!,
                                      field: 'weight',
                                      additionalField: 'raw_weight',
                                      value:
                                          '${sensor!.weight.toStringAsFixed(3)} kg',
                                      invalidAlias: 'load cell',
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  leading: const Icon(Icons.thermostat_auto),
                                  title: const Text("Product Temperature"),
                                  trailing: Text(
                                    _readingText(
                                      sensor!,
                                      field: 'ds_temperature',
                                      value: sensor!.dsTemperature == null
                                          ? '—'
                                          : '${sensor!.dsTemperature!.toStringAsFixed(1)}°C',
                                      invalidAlias: 'ds temp',
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  leading: const Icon(Icons.local_gas_station),
                                  title: const Text("Air Quality"),
                                  trailing: Text(
                                    _readingText(
                                      sensor!,
                                      field: 'gas',
                                      value:
                                          sensor!.gas?.toStringAsFixed(0) ??
                                          '—',
                                      invalidAlias: 'gas',
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _manualRefresh
                                ? null
                                : () => loadData(manual: true),
                            icon: _manualRefresh
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded),
                            label: Text(
                              _manualRefresh
                                  ? 'Updating device…'
                                  : 'Refresh now',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary
                                  .withOpacity(0.65),
                              disabledForegroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Text(
                            _lastUpdatedAt == null
                                ? 'Waiting for the next live update'
                                : 'Last refreshed ${_formatClock(_lastUpdatedAt!)}  •  Smart Karawala',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.hint,
                              fontSize: 11.5,
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
  }

  Widget _loadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 18),
          Text(
            'Connecting to the drying device…',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Checking sensors and controller outputs',
            style: TextStyle(color: AppColors.hint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => loadData(manual: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.09),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sensors_off_rounded,
                            color: AppColors.error,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Device data unavailable',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          _loadError ??
                              'No readings have been received from the device yet.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.hint,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: _manualRefresh
                              ? null
                              : () => loadData(manual: true),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try again'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'You can also pull down to refresh.',
                          style: TextStyle(color: AppColors.hint, fontSize: 11),
                        ),
                      ],
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

  Widget _pageHeader(SensorModel data) {
    final stale = _loadError != null;
    final warning = data.online && data.sensorErrors.isNotEmpty;
    final color = stale
        ? const Color(0xFFE99722)
        : !data.online
        ? AppColors.error
        : warning
        ? const Color(0xFFE99722)
        : AppColors.success;
    final label = stale
        ? 'LIVE DATA STALE'
        : !data.online
        ? 'DEVICE OFFLINE'
        : warning
        ? 'NEEDS ATTENTION'
        : 'ALL SYSTEMS READY';

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 540;
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device health overview',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 25,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Monitor the connection, sensors and drying equipment in one place.',
              style: TextStyle(
                color: AppColors.hint,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        );
        final status = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.25)),
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
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [heading, const SizedBox(height: 13), status],
          );
        }
        return Row(
          children: [
            Expanded(child: heading),
            const SizedBox(width: 14),
            status,
          ],
        );
      },
    );
  }

  Widget _errorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 7, 10),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.075),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.error.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _loadError!,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Try again',
            onPressed: _manualRefresh ? null : () => loadData(manual: true),
            color: AppColors.error,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _sensorIssueBanner(List<String> errors) {
    const warning = Color(0xFFE99722);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warning.withOpacity(0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: warning, size: 24),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${errors.length} sensor issue${errors.length == 1 ? '' : 's'} detected',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                ...errors
                    .take(3)
                    .map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          '• ${_friendlyError(error)}',
                          style: const TextStyle(
                            color: AppColors.hint,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                if (errors.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '+ ${errors.length - 3} more',
                      style: const TextStyle(
                        color: warning,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
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
            color: AppColors.primary.withOpacity(0.09),
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
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.hint,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actuatorGrid(SensorModel data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final tiles = [
          statusTile(
            icon: Icons.local_fire_department_rounded,
            title: 'Heater',
            status: _actuatorAvailable(data, 'heater') ? data.heater : null,
            activeColor: const Color(0xFFE95B4D),
          ),
          statusTile(
            icon: Icons.air_rounded,
            title: 'Exhaust fan',
            status: _actuatorAvailable(data, 'fan') ? data.fan : null,
            activeColor: AppColors.primary,
          ),
          statusTile(
            icon: Icons.lightbulb_rounded,
            title: 'Chamber light',
            status: _actuatorAvailable(data, 'light') ? data.light : null,
            activeColor: const Color(0xFFE99722),
          ),
        ];
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: tiles
              .map((tile) => SizedBox(width: width, child: tile))
              .toList(growable: false),
        );
      },
    );
  }

  Widget _readingsUnavailableCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFD5E8F3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.sensors_off_rounded, color: AppColors.hint, size: 34),
          SizedBox(height: 11),
          Text(
            'Live readings unavailable',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Reconnect the Arduino to view temperature, humidity, weight and air quality.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.hint, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  String _readingText(
    SensorModel data, {
    required String field,
    required String value,
    required String invalidAlias,
    String? additionalField,
  }) {
    if (!_readingAvailable(
      data,
      field: field,
      additionalField: additionalField,
      invalidAlias: invalidAlias,
    )) {
      return '—';
    }
    return value;
  }

  bool _readingAvailable(
    SensorModel data, {
    required String field,
    String? additionalField,
    required String invalidAlias,
  }) {
    if (_loadError != null || !data.online) return false;
    final missingFields = [field, if (additionalField != null) additionalField];
    for (final error in data.sensorErrors) {
      final normalized = error.toLowerCase();
      if (missingFields.any(
        (name) => normalized.contains('missing sensor value: $name'),
      )) {
        return false;
      }
      if (normalized.contains('invalid sensor line:') &&
          normalized.contains(invalidAlias)) {
        return false;
      }
    }
    return true;
  }

  bool _actuatorAvailable(SensorModel data, String field) {
    return _readingAvailable(data, field: field, invalidAlias: field);
  }

  String _friendlyError(String error) {
    final trimmed = error.trim();
    const prefix = 'Missing sensor value:';
    if (trimmed.toLowerCase().startsWith(prefix.toLowerCase())) {
      final field = trimmed.substring(prefix.length).trim();
      return '${_sensorName(field)} is not reporting a value.';
    }
    if (trimmed.toLowerCase().startsWith('invalid sensor line:')) {
      return 'The device sent a value that could not be read.';
    }
    return trimmed;
  }

  String _sensorName(String field) {
    switch (field.toLowerCase()) {
      case 'temperature':
        return 'Chamber temperature';
      case 'humidity':
        return 'Humidity sensor';
      case 'ds_temperature':
        return 'Product temperature probe';
      case 'gas':
        return 'Air-quality sensor';
      case 'raw_weight':
      case 'weight':
        return 'Load cell';
      case 'heater':
        return 'Heater state';
      case 'fan':
        return 'Fan state';
      case 'light':
        return 'Light state';
      default:
        return field.replaceAll('_', ' ');
    }
  }

  String _formatClock(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
