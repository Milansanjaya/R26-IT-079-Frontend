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
    isBedEmpty: true,
    detectedFishCount: 0,
    activeBatchId: "BATCH-20260830-01",
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

  // Batch Selection State
  String _selectedBatchId = "BATCH-20260830-01";
  List<String> _availableBatchIds = [
    "BATCH-20260830-01",
    "BATCH-20260829-04",
    "BATCH-20260829-02",
    "MANUAL-SESSION-01",
  ];

  // Live Vision Filter Toggles (Matching Verification Station Vision Engine)
  bool _sharpFocus = true;
  bool _showEdgeLines = true;
  bool _showDiscolorationLines = true;
  bool _showBboxes = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableBatches();
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

  Future<void> _fetchAvailableBatches() async {
    final batches = await VerificationStationService.fetchAvailableBatchIds();
    if (mounted && batches.isNotEmpty) {
      setState(() {
        _availableBatchIds = batches;
        if (!_availableBatchIds.contains(_selectedBatchId)) {
          _selectedBatchId = _availableBatchIds.first;
        }
      });
    }
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
    final data = await VerificationStationService.fetchTelemetry(
      host: _piHost,
      batchId: _selectedBatchId,
    );
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
      }
    });

    await VerificationStationService.sendControlAction(action, host: _piHost);
    await _fetchTelemetryData();
    if (mounted) {
      setState(() => _actionPending = false);
    }
  }

  Future<void> _calibrateEmptyBed() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📷 Baseline empty rack reference saved!"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
    await VerificationStationService.calibrateEmptyBedBaseline();
    setState(() {
      _telemetry = _telemetry.copyWith(isBedEmpty: true, detectedFishCount: 0);
    });
  }

  Future<void> _rescanDiscolorations() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🔄 Rescanning discolorations..."),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
      ),
    );
    await VerificationStationService.rescanDiscolorations();
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
            Text("Station Target Host", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the Station proxy or direct IP address:",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "http://localhost:3000 or http://172.20.10.2:8080",
                isDense: true,
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
            child: const Text("Save Target", style: TextStyle(color: Colors.white)),
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
    return "$sign${diff.toStringAsFixed(1)}$unit (3s)";
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Verification Station",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xff103F73),
              ),
            ),
            Text(
              "Session: $_selectedBatchId",
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          // Batch Selector Dropdown
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _availableBatchIds.contains(_selectedBatchId) ? _selectedBatchId : _availableBatchIds.first,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xff103F73), size: 18),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff103F73)),
                onChanged: (newBatch) {
                  if (newBatch != null) {
                    setState(() {
                      _selectedBatchId = newBatch;
                    });
                    _fetchTelemetryData();
                  }
                },
                items: _availableBatchIds.map((batchId) {
                  return DropdownMenuItem<String>(
                    value: batchId,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(batchId),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
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
                  border: Border.all(
                    color: _telemetry.isConnected ? Colors.grey.shade200 : Colors.red.shade200,
                  ),
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
                          decoration: BoxDecoration(
                            color: _telemetry.isConnected ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _telemetry.isConnected
                              ? "SMART MONITORING BACKEND ONLINE (PORT 8002)"
                              : "SMART MONITORING BACKEND OFFLINE",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _telemetry.isConnected ? Colors.green.shade800 : Colors.red,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (!_telemetry.isConnected) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              _fetchTelemetryData();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.refresh, size: 10, color: Colors.red),
                                  SizedBox(width: 2),
                                  Text(
                                    "Reconnect",
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _telemetry.isConnected
                            ? (isOptimalDrying ? Colors.green.withValues(alpha: 0.12) : Colors.amber.withValues(alpha: 0.12))
                            : Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _telemetry.isConnected
                              ? (isOptimalDrying ? Colors.green : Colors.amber)
                              : Colors.grey,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _telemetry.isConnected
                            ? (isOptimalDrying ? "🟢 OPTIMAL DRYING" : "⚠️ HUMIDITY WARNING")
                            : "🔴 OFFLINE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _telemetry.isConnected
                              ? (isOptimalDrying ? Colors.green.shade800 : Colors.amber.shade900)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Live View Camera Stream Card with Vision Overlay
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

                    // Live Vision Filters Overlay Bar (Matching Verification Station Pill Buttons)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xff0F172A),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.circle, color: Color(0xff10b981), size: 6),
                                SizedBox(width: 4),
                                Text(
                                  "LIVE VISION:",
                                  style: TextStyle(color: Color(0xff10b981), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),

                            // Focus Sharpening Toggle Pill
                            _buildVisionPillButton(
                              label: "🔍 Focus Sharpening ${_sharpFocus ? 'ON' : 'OFF'}",
                              isActive: _sharpFocus,
                              activeColor: const Color(0xffc084fc),
                              activeBg: const Color(0x40a855f7),
                              borderColor: const Color(0xffa855f7),
                              onTap: () => setState(() => _sharpFocus = !_sharpFocus),
                            ),
                            const SizedBox(width: 6),

                            // Calibrate Empty Bed Action Pill
                            _buildVisionPillButton(
                              label: "📷 Calibrate Empty Bed",
                              isActive: true,
                              activeColor: const Color(0xff60a5fa),
                              activeBg: const Color(0x403b82f6),
                              borderColor: const Color(0xff3b82f6),
                              onTap: _calibrateEmptyBed,
                            ),
                            const SizedBox(width: 6),

                            // Rescan Discolorations Action Pill
                            _buildVisionPillButton(
                              label: "🔄 Rescan Discolorations (10s)",
                              isActive: true,
                              activeColor: const Color(0xfff87171),
                              activeBg: const Color(0x33ef4444),
                              borderColor: const Color(0x80ef4444),
                              onTap: _rescanDiscolorations,
                            ),
                            const SizedBox(width: 6),

                            // Contour Lines Toggle Pill
                            _buildVisionPillButton(
                              label: "⚡ Contour Lines ${_showEdgeLines ? 'ON' : 'OFF'}",
                              isActive: _showEdgeLines,
                              activeColor: const Color(0xff34d399),
                              activeBg: const Color(0x4010b981),
                              borderColor: const Color(0xff10b981),
                              onTap: () => setState(() => _showEdgeLines = !_showEdgeLines),
                            ),
                            const SizedBox(width: 6),

                            // Color Discolorations Toggle Pill
                            _buildVisionPillButton(
                              label: "🔴 Color Discolorations ${_showDiscolorationLines ? 'ON' : 'OFF'}",
                              isActive: _showDiscolorationLines,
                              activeColor: const Color(0xfff87171),
                              activeBg: const Color(0x40ef4444),
                              borderColor: const Color(0xffef4444),
                              onTap: () => setState(() => _showDiscolorationLines = !_showDiscolorationLines),
                            ),
                            const SizedBox(width: 6),

                            // BBoxes Toggle Pill
                            _buildVisionPillButton(
                              label: "🟦 BBoxes",
                              isActive: _showBboxes,
                              activeColor: const Color(0xff60a5fa),
                              activeBg: const Color(0x403b82f6),
                              borderColor: const Color(0xff3b82f6),
                              onTap: () => setState(() => _showBboxes = !_showBboxes),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Drying Bed Occupancy & Sample Status Tile
              _buildBedOccupancyStatusCard(),

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
                    mainValue: _telemetry.isConnected ? "${_telemetry.temperatureC.toStringAsFixed(1)}°C" : "--",
                    subValue: _telemetry.isConnected ? "${_telemetry.temperatureF.toStringAsFixed(1)}°F" : "Disconnected",
                    trendText: _telemetry.isConnected ? _calculateTrendText(_telemetry.tempHistory, "°C") : "Offline",
                    history: _telemetry.tempHistory,
                    icon: Icons.thermostat,
                    lineColor: Colors.orange.shade700,
                    accentColor: const Color(0xffFFF3E0),
                  ),

                  // Humidity (RH) with Sparkline
                  _buildMetricSparklineTile(
                    title: "HUMIDITY (RH)",
                    mainValue: _telemetry.isConnected ? "${_telemetry.humidityPercent.toStringAsFixed(1)}%" : "--",
                    subValue: _telemetry.isConnected ? (isOptimalDrying ? "Optimal" : "Elevated") : "Disconnected",
                    trendText: _telemetry.isConnected ? _calculateTrendText(_telemetry.humidityHistory, "%") : "Offline",
                    history: _telemetry.humidityHistory,
                    icon: Icons.water_drop,
                    lineColor: Colors.blue.shade600,
                    accentColor: const Color(0xffE3F2FD),
                  ),

                  // MQ2 Gas Sensor with Sparkline
                  _buildMetricSparklineTile(
                    title: "MQ2 GAS SENSOR",
                    mainValue: _telemetry.isConnected ? _telemetry.gasRaw.toStringAsFixed(0) : "--",
                    subValue: _telemetry.isConnected ? "Raw Analog PPM" : "Disconnected",
                    trendText: _telemetry.isConnected ? _calculateTrendText(_telemetry.gasHistory, "") : "Offline",
                    history: _telemetry.gasHistory,
                    icon: Icons.air,
                    lineColor: Colors.teal.shade600,
                    accentColor: const Color(0xffE0F2F1),
                  ),

                  // HX711 Load Cell with Sparkline
                  _buildMetricSparklineTile(
                    title: "LOAD CELL (WEIGHT)",
                    mainValue: _telemetry.isConnected ? "${_telemetry.loadCellRaw.toStringAsFixed(0)} g" : "--",
                    subValue: _telemetry.isConnected ? "HX711 Reading" : "Disconnected",
                    trendText: _telemetry.isConnected ? _calculateTrendText(_telemetry.weightHistory, "g") : "Offline",
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

              // Hardware Actuator Controls Panel (Light Only + Tare)
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
                            Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
                            SizedBox(width: 6),
                            Text(
                              "Hardware Light Control",
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
                    const SizedBox(height: 14),

                    // Single Dedicated Light Control Card
                    GestureDetector(
                      onTap: _actionPending
                          ? null
                          : () => _handleControlAction(
                                _telemetry.lightState ? 'light_off' : 'light_on',
                              ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _telemetry.lightState ? const Color(0xffFFF8E1) : const Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _telemetry.lightState ? Colors.amber.shade400 : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: _telemetry.lightState
                              ? [
                                  BoxShadow(
                                    color: Colors.amber.shade200.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _telemetry.lightState ? Colors.amber.shade700 : Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _telemetry.lightState ? Icons.lightbulb : Icons.lightbulb_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Drying Bed Light",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _telemetry.lightState ? Colors.amber.shade900 : const Color(0xff103F73),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _telemetry.lightState
                                        ? "Light is turned ON • Tap to turn off"
                                        : "Light is turned OFF • Tap to turn on",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _telemetry.lightState ? Colors.amber.shade800 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _telemetry.lightState,
                              activeThumbColor: Colors.amber.shade700,
                              activeTrackColor: Colors.amber.shade200,
                              onChanged: _actionPending
                                  ? null
                                  : (val) => _handleControlAction(val ? 'light_on' : 'light_off'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Hardware Info Footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.developer_board, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hardware Engine: Arduino Nano + Computer Vision System",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            "IoT Service: http://localhost:8002/api/iot • Camera Target: $_piHost",
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vision Pill Button Helper
  Widget _buildVisionPillButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color activeBg,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? borderColor : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? activeColor : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Bed Occupancy Status Card Widget
  Widget _buildBedOccupancyStatusCard() {
    final isEmpty = _telemetry.isBedEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmpty ? const Color(0xffFFFBEB) : const Color(0xffF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEmpty ? const Color(0xffFCD34D) : const Color(0xff86EFAC),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isEmpty ? Colors.amber : Colors.green).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isEmpty ? const Color(0xffFEF3C7) : const Color(0xffDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEmpty ? Icons.grid_off_outlined : Icons.set_meal_outlined,
                  color: isEmpty ? const Color(0xffD97706) : const Color(0xff16A34A),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmpty ? "NO FISH DETECTED ON BED" : "FISH SAMPLE DETECTED ON BED",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: isEmpty ? const Color(0xffB45309) : const Color(0xff15803D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEmpty
                          ? "Place a fish sample on the drying rack to start live quality & dryness monitoring."
                          : "Live quality, moisture reduction rate, and discoloration scan active.",
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: isEmpty ? const Color(0xff92400E) : const Color(0xff166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildVisionStatusBadge(
                  icon: "🔥",
                  title: "DRYING STAGE:",
                  value: _telemetry.dryingStage,
                  color: const Color(0xffc084fc),
                  bg: const Color(0x20a855f7),
                  border: const Color(0xffa855f7),
                ),
                _buildVisionStatusBadge(
                  icon: "🏆",
                  title: "LIVE QUALITY:",
                  value: _telemetry.liveQuality,
                  color: _telemetry.colorDiscolorationsCount == 0 ? const Color(0xff34d399) : const Color(0xfff87171),
                  bg: _telemetry.colorDiscolorationsCount == 0 ? const Color(0x2010b981) : const Color(0x20ef4444),
                  border: _telemetry.colorDiscolorationsCount == 0 ? const Color(0xff10b981) : const Color(0xffef4444),
                ),
                _buildVisionStatusBadge(
                  icon: "💧",
                  title: "DRYNESS LEVEL:",
                  value: _telemetry.drynessLevel,
                  color: const Color(0xff60a5fa),
                  bg: const Color(0x203b82f6),
                  border: const Color(0xff3b82f6),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Color Match: ${_telemetry.colorMatchPercent}%",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Text(
                  "Discolorations: ${_telemetry.colorDiscolorationsCount}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _telemetry.colorDiscolorationsCount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Samples: ${_telemetry.detectedFishCount} In Frame",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildOccupancyPill(
                  icon: Icons.warning_amber_rounded,
                  label: "BED STATUS: EMPTY TRAY",
                  color: const Color(0xffD97706),
                  bg: const Color(0xffFEF3C7),
                ),
                const SizedBox(width: 8),
                _buildOccupancyPill(
                  icon: Icons.camera_alt_outlined,
                  label: "VISION SCAN: STANDBY",
                  color: const Color(0xff475569),
                  bg: const Color(0xffE2E8F0),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisionStatusBadge({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required Color bg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildOccupancyPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ],
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
      padding: const EdgeInsets.all(12),
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: lineColor, size: 14),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainValue,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff103F73),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                subValue,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
          Text(
            "Trend: $trendText",
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: trendText.contains("+")
                  ? Colors.red.shade700
                  : (trendText.contains("-") ? Colors.green.shade700 : Colors.grey.shade600),
            ),
          ),
          SizedBox(
            height: 28,
            child: MiniSparklineChart(
              values: history,
              lineColor: lineColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsComparisonCard() {
    final liveTemp = _telemetry.temperatureC;
    final targetTemp = _prediction.predictedTempC;
    final liveHumidity = _telemetry.humidityPercent;
    final targetHumidity = _prediction.predictedHumidityPercent;

    return Container(
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
                  Icon(Icons.auto_graph, color: AppColors.primary, size: 20),
                  SizedBox(width: 6),
                  Text(
                    "Live Telemetry vs AI Predicted Target",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff103F73),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _prediction.fishType,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Temperature Comparison Bar
          _buildComparisonRow(
            label: "Temperature Target",
            liveText: "Live: ${liveTemp.toStringAsFixed(1)}°C",
            targetText: "(${targetTemp.toStringAsFixed(1)}°C Target)",
            ratio: (liveTemp / (targetTemp > 0 ? targetTemp : 40.0)).clamp(0.0, 1.0),
            color: Colors.orange.shade700,
            statusLabel: (liveTemp - targetTemp).abs() < 2.0 ? "Target Met" : "Adjusting",
          ),
          const SizedBox(height: 12),

          // Humidity Comparison Bar
          _buildComparisonRow(
            label: "Humidity Target",
            liveText: "Live: ${liveHumidity.toStringAsFixed(1)}%",
            targetText: "(${targetHumidity.toStringAsFixed(1)}% Target)",
            ratio: (liveHumidity / 100.0).clamp(0.0, 1.0),
            color: Colors.blue.shade600,
            statusLabel: liveHumidity <= targetHumidity ? "Optimal RH" : "Elevated RH",
          ),
          const SizedBox(height: 16),

          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),

          // Predictions Summary Footer Cards
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ESTIMATED DRYING TIME", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text(
                          "${_prediction.estimatedDurationHours.toStringAsFixed(1)} Hours Remaining",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff103F73)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.security, color: Colors.teal, size: 18),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("SPOILAGE RISK", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text(
                          "${(_prediction.spoilageRisk * 100).toStringAsFixed(1)}% (Low / Safe)",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String liveText,
    required String targetText,
    required double ratio,
    required Color color,
    required String statusLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
            Row(
              children: [
                Text(liveText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(width: 4),
                Text(targetText, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
