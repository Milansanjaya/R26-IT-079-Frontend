import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/Drying/time_prediction_service.dart';
import '../../services/iot_service.dart';

/// Fallback readings used when the IoT device can't be reached or is offline.
const double _fallbackHumidityPercent = 60.0;
const double _fallbackMq136Value = 0.0;

class TimePredictionScreen extends StatefulWidget {
  final String batchId;
  final String fishType;
  final double initialWeightKg;
  final bool saltedCompleted;

  const TimePredictionScreen({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.initialWeightKg,
    this.saltedCompleted = false,
  });

  @override
  State<TimePredictionScreen> createState() => _TimePredictionScreenState();
}

class _TimePredictionScreenState extends State<TimePredictionScreen> {
  bool _loading = false;
  bool _predicted = false;
  double _recommendedTemperature = 0;
  double _estimatedHours = 0;
  String? _error;
  String? _iotWarning;
  bool _usedLiveReadings = false;

  Future<void> _predict() async {
    if (!widget.saltedCompleted) {
      setState(() {
        _error = 'This batch must be salted and the salting process must be completed before drying prediction.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _iotWarning = null;
    });

    double humidityPercent = _fallbackHumidityPercent;
    double mq136Value = _fallbackMq136Value;
    bool usedLiveReadings = false;
    String? iotWarning;

    try {
      final sensor = await IotService.getLiveData();
      if (sensor.online) {
        humidityPercent = sensor.humidity;
        mq136Value = sensor.gas ?? _fallbackMq136Value;
        usedLiveReadings = true;
      } else {
        iotWarning = 'IoT device is offline. Using default initial readings instead of live sensor data.';
      }
    } catch (_) {
      iotWarning = 'Could not reach the IoT device. Using default initial readings instead of live sensor data.';
    }

    if (mounted && iotWarning != null) {
      setState(() {
        _iotWarning = iotWarning;
      });
    }

    try {
      final result = await TimePredictionService.predictInitial(
        fishType: widget.fishType,
        initialWeightKg: widget.initialWeightKg,
        humidityPercent: humidityPercent,
        mq136Value: mq136Value,
      );

      if (!mounted) return;

      setState(() {
        _recommendedTemperature = (result['recommended_temperature_c'] as num?)?.toDouble() ?? 0.0;
        _estimatedHours = (result['estimated_total_drying_time_hours'] as num?)?.toDouble() ?? 0.0;
        _usedLiveReadings = usedLiveReadings;
        _predicted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _formatHours(double hours) {
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Time Prediction',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Initial drying estimate',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'The batch must already be salted and the salting step completed before this estimate is used.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Batch ID', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 6),
                    Text(
                      widget.batchId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile('Fish type', widget.fishType),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoTile('Weight', '${widget.initialWeightKg.toStringAsFixed(1)} kg'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _predict,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.av_timer_rounded),
                  label: Text(_loading ? 'Predicting...' : 'Predict Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              if (_iotWarning != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _iotWarning!,
                          style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_predicted) ...[
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                      const Text(
                        'Estimated total drying time',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatHours(_estimatedHours),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 18),
                      const Text(
                        'Recommended drying temperature',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_recommendedTemperature.toStringAsFixed(1)} °C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _usedLiveReadings ? Icons.sensors : Icons.sensors_off,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _usedLiveReadings
                                ? 'Based on live IoT sensor readings'
                                : 'Based on default initial readings',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
