import 'dart:async';

import 'package:flutter/material.dart';

import 'alerts_screen.dart';
import 'device_status_screen.dart';
import 'drying_control_screen.dart';
import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';
import '../../widgets/drying/live_chart.dart';
import '../../widgets/drying/progress_card.dart';
import '../../widgets/drying/sensor_card.dart';
import '../../widgets/drying/status_tile.dart';

class DryingDashboardScreen extends StatefulWidget {
  const DryingDashboardScreen({super.key});

  @override
  State<DryingDashboardScreen> createState() => _DryingDashboardScreenState();
}

class _DryingDashboardScreenState extends State<DryingDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SensorModel? sensor;
  bool loading = true;
  Timer? timer;

  final List<double> tempHistory = [];
  final List<double> humidityHistory = [];

  bool get hasSensorData => sensor != null;

  String get temperatureValue => hasSensorData ? "${sensor!.temperature} °C" : "--";
  String get humidityValue => hasSensorData ? "${sensor!.humidity} %" : "--";
  String get weightValue => hasSensorData ? "${sensor!.weight} kg" : "--";
  String get deviceStatusText => hasSensorData ? "Device Online" : "Awaiting live sensor data";
  Color get deviceStatusColor => hasSensorData ? Colors.green : Colors.orange;

  @override
  void initState() {
    super.initState();
    loadSensor();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => loadSensor());
  }

  Future<void> loadSensor() async {
    try {
      final data = await IotService.getLiveData();

      if (!mounted) return;

      setState(() {
        sensor = data;
        loading = false;

        tempHistory.add(data.temperature);
        humidityHistory.add(data.humidity);

        if (tempHistory.length > 20) {
          tempHistory.removeAt(0);
        }

        if (humidityHistory.length > 20) {
          humidityHistory.removeAt(0);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xff234D73),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 15),
                Text(
                  "Smart Karawala",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Drying Module",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text("Drying Control"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DryingControlScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text("Alerts"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlertsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text("Device Status"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeviceStatusScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text("Close"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu),
                  ),
                ),
                Image.asset(
                  "assets/images/logo.png",
                  width: 70,
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Drying Dashboard",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color(0xff234D73),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: deviceStatusColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        deviceStatusText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "ARDUINO-NANO",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (!hasSensorData) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orangeAccent),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Live sensor values are not available right now, but the dashboard UI is still visible.",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1,
              children: [
                SensorCard(
                  icon: Icons.thermostat,
                  title: "Temperature",
                  value: temperatureValue,
                  subtitle: hasSensorData ? "Target : 50°C" : "Waiting for data",
                  color: Colors.red,
                ),
                SensorCard(
                  icon: Icons.water_drop,
                  title: "Humidity",
                  value: humidityValue,
                  subtitle: hasSensorData ? "Target : 40%" : "Waiting for data",
                  color: Colors.green,
                ),
                SensorCard(
                  icon: Icons.scale,
                  title: "Weight",
                  value: weightValue,
                  subtitle: hasSensorData ? "Live Weight" : "Waiting for data",
                  color: Colors.deepPurple,
                ),
                ProgressCard(
                  progress: hasSensorData ? 62 : 0,
                ),
              ],
            ),
            const SizedBox(height: 25),
            LiveChart(
              title: "Temperature & Humidity",
              temperatures: tempHistory,
              humidities: humidityHistory,
            ),
            const SizedBox(height: 25),
            const Text(
              "Device Status",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            StatusTile(
              icon: Icons.local_fire_department,
              title: "Heater",
              status: sensor?.heater,
            ),
            const SizedBox(height: 10),
            StatusTile(
              icon: Icons.air,
              title: "Fan",
              status: sensor?.fan,
            ),
            const SizedBox(height: 10),
            StatusTile(
              icon: Icons.lightbulb,
              title: "Light",
              status: sensor?.light,
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Powered by Smart Karawala",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xffEAF7FF),
      drawer: _drawer(),
      body: loading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
    );
  }
}