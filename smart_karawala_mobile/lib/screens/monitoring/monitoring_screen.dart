import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/telemetry_model.dart';
import '../../services/verification_station_service.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  Timer? _telemetryTimer;
  TelemetryData _telemetry = TelemetryData(
    temperatureC: 34.2,
    temperatureF: 93.56,
    humidityPercent: 48.0,
    gasRaw: 280.0,
    loadCellRaw: 1250.0,
    heaterState: false,
    lightState: true,
    fanState: true,
  );

  bool _actionPending = false;
  String _piHost = "http://localhost:3000";
  int _streamKey = 0;
  final bool _isCameraConnected = true;

  @override
  void initState() {
    super.initState();
    _fetchTelemetryData();
    _startTelemetryTimer();
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
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

  Future<void> _handleControlAction(String action) async {
    setState(() => _actionPending = true);
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
                _streamKey++;
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
              "Live Monitoring & Controls",
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
                      color: Colors.black.withOpacity(0.03),
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
                            ? Colors.green.withOpacity(0.12)
                            : Colors.amber.withOpacity(0.12),
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
                      color: Colors.black.withOpacity(0.15),
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
                                  setState(() => _streamKey++);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
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

                    // Camera Stream Video Container
                    Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.black,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isCameraConnected)
                            Image.network(
                              VerificationStationService.getStreamUrl(host: _piHost),
                              key: ValueKey(_streamKey),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xff0F172A),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.videocam_off_outlined, color: Colors.amber, size: 48),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Camera Feed Connecting...",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Target: $_piHost/api/camera/stream",
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        ),
                                        onPressed: () {
                                          setState(() => _streamKey++);
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
                          // Live Indicator Overlay
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.85),
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section Title: Real-time Telemetry
              const Text(
                "Real-time Environmental Telemetry",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff103F73),
                ),
              ),
              const SizedBox(height: 12),

              // 4 Metrics Grid (Temp, Humidity, Gas, Load Cell)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Air Temp (SHT30)
                  _buildMetricTile(
                    title: "AIR TEMP (SHT30)",
                    mainValue: "${_telemetry.temperatureC.toStringAsFixed(1)}°C",
                    subValue: "${_telemetry.temperatureF.toStringAsFixed(1)}°F",
                    icon: Icons.thermostat,
                    iconColor: Colors.orange.shade700,
                    accentColor: const Color(0xffFFF3E0),
                    statusText: _telemetry.temperatureC > 40.0 ? "High Temp" : "Normal Temp",
                    statusColor: _telemetry.temperatureC > 40.0 ? Colors.red : Colors.orange.shade800,
                  ),

                  // Humidity (RH)
                  _buildMetricTile(
                    title: "HUMIDITY (RH)",
                    mainValue: "${_telemetry.humidityPercent.toStringAsFixed(1)}%",
                    subValue: isOptimalDrying ? "Optimal Range" : "Elevated RH",
                    icon: Icons.water_drop,
                    iconColor: Colors.blue.shade600,
                    accentColor: const Color(0xffE3F2FD),
                    statusText: isOptimalDrying ? "Optimal" : "Warning",
                    statusColor: isOptimalDrying ? Colors.green : Colors.amber.shade900,
                  ),

                  // MQ2 Gas Sensor
                  _buildMetricTile(
                    title: "MQ2 GAS SENSOR",
                    mainValue: _telemetry.gasRaw.toStringAsFixed(0),
                    subValue: "Raw Analog PPM",
                    icon: Icons.air,
                    iconColor: Colors.teal.shade600,
                    accentColor: const Color(0xffE0F2F1),
                    statusText: _telemetry.gasRaw > 400 ? "Gas Alert!" : "Air Safe",
                    statusColor: _telemetry.gasRaw > 400 ? Colors.red : Colors.teal.shade800,
                  ),

                  // HX711 Load Cell
                  _buildMetricTile(
                    title: "LOAD CELL (WEIGHT)",
                    mainValue: "${_telemetry.loadCellRaw.toStringAsFixed(0)} g",
                    subValue: "HX711 Reading",
                    icon: Icons.scale,
                    iconColor: Colors.purple.shade600,
                    accentColor: const Color(0xffF3E5F5),
                    statusText: "Active Scale",
                    statusColor: Colors.purple.shade800,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Hardware Actuator Controls Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
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
                        // Tare scale button
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
                        // Light Control Button (Mainly requested by user)
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

  Widget _buildMetricTile({
    required String title,
    required String mainValue,
    required String subValue,
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mainValue,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              Text(
                subValue,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
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
