import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/telemetry_model.dart';
import '../../services/verification_station_service.dart';
import '../../widgets/monitoring/mini_sparkline_chart.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  Timer? _telemetryTimer;
  Timer? _frameTimer;

  TelemetryData _telemetry = TelemetryData(
    temperatureC: 0.0,
    temperatureF: 0.0,
    humidityPercent: 0.0,
    gasRaw: 0.0,
    loadCellRaw: 0.0,
    heaterState: false,
    lightState: true,
    fanState: true,
  );

  PredictionData _prediction = PredictionData(
    predictedTempC: 36.0,
    predictedHumidityPercent: 42.0,
    estimatedDurationHours: 4.5,
    spoilageRisk: 0.04,
    fishType: "Katta / Sailfish",
  );

  bool _actionPending = false;
  String _piHost = "http://localhost:3000";
  bool _useSnapshotMode = true;
  final bool _isCameraConnected = true;

  @override
  void initState() {
    super.initState();
    _fetchTelemetryData();
    _fetchPredictionData();
    _startTelemetryTimer();
    _startFrameTimer();
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _frameTimer?.cancel();
    super.dispose();
  }

  void _startFrameTimer() {
    _frameTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (mounted && _useSnapshotMode) {
        setState(() {});
      }
    });
  }

  void _startTelemetryTimer() {
    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchTelemetryData();
    });
  }

  Future<void> _fetchTelemetryData() async {
    final data = await VerificationStationService.fetchTelemetry(host: _piHost);
    if (mounted) {
      setState(() {
        _telemetry = data;
      });
    }
  }

  Future<void> _fetchPredictionData() async {
    final pred = await VerificationStationService.fetchPredictions();
    if (mounted) {
      setState(() {
        _prediction = pred;
      });
    }
  }

  Future<void> _handleControlAction(String action) async {
    setState(() {
      _actionPending = true;
      if (action == 'light_on') {
        _telemetry = _telemetry.copyWith(lightState: true);
      } else if (action == 'light_off') {
        _telemetry = _telemetry.copyWith(lightState: false);
      } else if (action == 'heater_on') {
        _telemetry = _telemetry.copyWith(heaterState: true);
      } else if (action == 'heater_off') {
        _telemetry = _telemetry.copyWith(heaterState: false);
      } else if (action == 'fan_on') {
        _telemetry = _telemetry.copyWith(fanState: true);
      } else if (action == 'fan_off') {
        _telemetry = _telemetry.copyWith(fanState: false);
      }
    });

    await VerificationStationService.sendControlAction(action, host: _piHost);
    await _fetchTelemetryData();
    if (mounted) {
      setState(() => _actionPending = false);
    }
  }

  void _showHostConfigDialog() {
    final controller = TextEditingController(text: _piHost);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings, color: AppColors.primary),
            SizedBox(width: 8),
            Text("Verification Station IP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the URL or IP address of your Raspberry Pi / Verification Station server:",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "e.g., http://192.168.1.100:3000",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                _piHost = controller.text.trim();
              });
              _fetchTelemetryData();
              Navigator.pop(ctx);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _calculateTrendText(List<double> history, String unit) {
    if (history.length < 2) return "Stable";
    final diff = history.last - history[history.length - 2];
    if (diff.abs() < 0.05) return "Stable";
    final sign = diff > 0 ? "+" : "";
    final arrow = diff > 0 ? "📈" : "📉";
    return "$arrow $sign${diff.toStringAsFixed(1)}$unit";
  }

  @override
  Widget build(BuildContext context) {
    final isOptimalDrying = _telemetry.humidityPercent < 55.0;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff103F73), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verification Station",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff103F73),
              ),
            ),
            Text(
              "Live Monitoring & Predictions",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xff103F73)),
            onPressed: _showHostConfigDialog,
            tooltip: "Configure Station Host",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Station Status Badge Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "HARDWARE ONLINE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOptimalDrying
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOptimalDrying ? Colors.green : Colors.amber,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        isOptimalDrying ? "🟢 OPTIMAL DRYING" : "⚠️ HUMIDITY WARNING",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOptimalDrying ? Colors.green.shade800 : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Live View Camera Stream Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Stream Viewport Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xff1E293B),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.videocam, color: Colors.redAccent, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "LIVE CAMERA STREAM",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _useSnapshotMode = !_useSnapshotMode;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _useSnapshotMode
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _useSnapshotMode ? Colors.green : Colors.transparent,
                                    ),
                                  ),
                                  child: Text(
                                    _useSnapshotMode ? "SNAPSHOT MODE" : "DIRECT STREAM",
                                    style: TextStyle(
                                      color: _useSnapshotMode ? Colors.greenAccent : Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.refresh, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Camera Stream Video Container (16:9 Aspect Ratio)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isCameraConnected)
                              Image.network(
                                _useSnapshotMode
                                    ? VerificationStationService.getSnapshotUrl(host: _piHost)
                                    : VerificationStationService.getStreamUrl(host: _piHost),
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                gaplessPlayback: true,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xff0F172A),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.videocam_off_outlined, color: Colors.amber, size: 44),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Camera Feed Connecting...",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Target: $_piHost/api/camera/${_useSnapshotMode ? 'snapshot' : 'stream'}",
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          ),
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.refresh, size: 14, color: Colors.white),
                                          label: const Text("Retry Stream", style: TextStyle(fontSize: 12, color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                          else
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.linked_camera, color: Colors.white54, size: 48),
                                SizedBox(height: 8),
                                Text("Camera Standby", style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.circle, color: Colors.white, size: 8),
                                  SizedBox(width: 4),
                                  Text(
                                    "LIVE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

              const SizedBox(height: 20),

              // Section Title: Real-time Telemetry Tiles with Sparklines
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Real-time Sensor Trends",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff103F73),
                    ),
                  ),
                  Text(
                    "Auto-updating (3s)",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4 Metrics Grid with Sparklines inside each tile
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Air Temp (SHT30) with Sparkline
                  _buildMetricSparklineTile(
                    title: "AIR TEMP (SHT30)",
                    mainValue: "${_telemetry.temperatureC.toStringAsFixed(1)}°C",
                    subValue: "${_telemetry.temperatureF.toStringAsFixed(1)}°F",
                    trendText: _calculateTrendText(_telemetry.tempHistory, "°C"),
                    history: _telemetry.tempHistory,
                    icon: Icons.thermostat,
                    lineColor: Colors.orange.shade700,
                    accentColor: const Color(0xffFFF3E0),
                  ),

                  // Humidity (RH) with Sparkline
                  _buildMetricSparklineTile(
                    title: "HUMIDITY (RH)",
                    mainValue: "${_telemetry.humidityPercent.toStringAsFixed(1)}%",
                    subValue: isOptimalDrying ? "Optimal" : "Elevated",
                    trendText: _calculateTrendText(_telemetry.humidityHistory, "%"),
                    history: _telemetry.humidityHistory,
                    icon: Icons.water_drop,
                    lineColor: Colors.blue.shade600,
                    accentColor: const Color(0xffE3F2FD),
                  ),

                  // MQ2 Gas Sensor with Sparkline
                  _buildMetricSparklineTile(
                    title: "MQ2 GAS SENSOR",
                    mainValue: _telemetry.gasRaw.toStringAsFixed(0),
                    subValue: "Raw Analog PPM",
                    trendText: _calculateTrendText(_telemetry.gasHistory, ""),
                    history: _telemetry.gasHistory,
                    icon: Icons.air,
                    lineColor: Colors.teal.shade600,
                    accentColor: const Color(0xffE0F2F1),
                  ),

                  // HX711 Load Cell with Sparkline
                  _buildMetricSparklineTile(
                    title: "LOAD CELL (WEIGHT)",
                    mainValue: "${_telemetry.loadCellRaw.toStringAsFixed(0)} g",
                    subValue: "HX711 Reading",
                    trendText: _calculateTrendText(_telemetry.weightHistory, "g"),
                    history: _telemetry.weightHistory,
                    icon: Icons.scale,
                    lineColor: Colors.purple.shade600,
                    accentColor: const Color(0xffF3E5F5),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Live Telemetry vs AI Predicted Target Parameters Comparison Panel
              _buildPredictionsComparisonCard(),

              const SizedBox(height: 20),

              // Hardware Actuator Controls Panel (Light, Heater, Fan, Tare)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: Colors.amber, size: 22),
                            SizedBox(width: 6),
                            Text(
                              "Hardware Actuator Controls",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff103F73),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _actionPending ? null : () => _handleControlAction('tare'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Row(
                              children: [
                                Text("⚖️", style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  "Tare Scale",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Controls Grid: Light, Heater, Fan
                    Row(
                      children: [
                        // Light Control Button
                        Expanded(
                          child: _buildActuatorButton(
                            label: "Light",
                            icon: Icons.lightbulb,
                            isOn: _telemetry.lightState,
                            activeColor: Colors.amber.shade700,
                            activeBg: const Color(0xffFFF8E1),
                            onTap: () => _handleControlAction(
                              _telemetry.lightState ? 'light_off' : 'light_on',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Heater Control Button
                        Expanded(
                          child: _buildActuatorButton(
                            label: "Heater",
                            icon: Icons.local_fire_department,
                            isOn: _telemetry.heaterState,
                            activeColor: Colors.red.shade600,
                            activeBg: const Color(0xffFFEBEE),
                            onTap: () => _handleControlAction(
                              _telemetry.heaterState ? 'heater_off' : 'heater_on',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Fan Control Button
                        Expanded(
                          child: _buildActuatorButton(
                            label: "Fan",
                            icon: Icons.air,
                            isOn: _telemetry.fanState,
                            activeColor: Colors.blue.shade600,
                            activeBg: const Color(0xffE3F2FD),
                            onTap: () => _handleControlAction(
                              _telemetry.fanState ? 'fan_off' : 'fan_on',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Hardware Info Footer Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.memory, color: Color(0xff475569), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hardware: Arduino Nano + Raspberry Pi (/dev/ttyUSB0)",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff334155),
                            ),
                          ),
                          Text(
                            "Telemetry Target: $_piHost • uStreamer HW Passthrough",
                            style: const TextStyle(fontSize: 10, color: Color(0xff64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSparklineTile({
    required String title,
    required String mainValue,
    required String subValue,
    required String trendText,
    required List<double> history,
    required IconData icon,
    required Color lineColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: lineColor, size: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trendText,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: lineColor,
                  ),
                ),
              ),
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainValue,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: lineColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                subValue,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          // Sparkline mini line chart
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: MiniSparklineChart(
              values: history,
              lineColor: lineColor,
              fillColor: accentColor,
              height: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsComparisonCard() {
    final liveTemp = _telemetry.temperatureC;
    final targetTemp = _prediction.predictedTempC;
    final tempDiff = (liveTemp - targetTemp).abs();

    final liveHumidity = _telemetry.humidityPercent;
    final targetHumidity = _prediction.predictedHumidityPercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.insights, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Live Telemetry vs AI Predicted Target",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff103F73),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _prediction.fishType,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Temperature Comparison Bar
          _buildComparisonRow(
            label: "Temperature Target",
            liveValueStr: "${liveTemp.toStringAsFixed(1)}°C",
            targetValueStr: "${targetTemp.toStringAsFixed(1)}°C Target",
            progressRatio: (liveTemp / 50.0).clamp(0.0, 1.0),
            targetRatio: (targetTemp / 50.0).clamp(0.0, 1.0),
            barColor: tempDiff < 2.0 ? Colors.green : Colors.orange,
            statusBadge: tempDiff < 2.0 ? "On Target" : "Adjusting",
          ),

          const SizedBox(height: 12),

          // Humidity Comparison Bar
          _buildComparisonRow(
            label: "Humidity Target",
            liveValueStr: "${liveHumidity.toStringAsFixed(1)}%",
            targetValueStr: "${targetHumidity.toStringAsFixed(1)}% Target",
            progressRatio: (liveHumidity / 100.0).clamp(0.0, 1.0),
            targetRatio: (targetHumidity / 100.0).clamp(0.0, 1.0),
            barColor: liveHumidity <= targetHumidity + 5.0 ? Colors.blue : Colors.amber.shade800,
            statusBadge: liveHumidity <= targetHumidity + 5.0 ? "Optimal" : "Elevated RH",
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xffE2E8F0)),
          const SizedBox(height: 12),

          // Estimated Duration Countdown & Spoilage Risk
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.indigo, size: 18),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ESTIMATED DRYING TIME",
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        "${_prediction.estimatedDurationHours.toStringAsFixed(1)} Hours Remaining",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.security, color: Colors.teal, size: 18),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SPOILAGE RISK",
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Text(
                        "${(_prediction.spoilageRisk * 100).toStringAsFixed(1)}% (Low / Safe)",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String liveValueStr,
    required String targetValueStr,
    required double progressRatio,
    required double targetRatio,
    required Color barColor,
    required String statusBadge,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            Row(
              children: [
                Text(
                  "Live: $liveValueStr",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                ),
                const SizedBox(width: 6),
                Text(
                  "($targetValueStr)",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusBadge,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: barColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 7,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progressRatio,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActuatorButton({
    required String label,
    required IconData icon,
    required bool isOn,
    required Color activeColor,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _actionPending ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isOn ? activeBg : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOn ? activeColor : Colors.grey.shade300,
            width: isOn ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isOn ? activeColor : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isOn ? activeColor : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isOn ? activeColor : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isOn ? "ON" : "OFF",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
