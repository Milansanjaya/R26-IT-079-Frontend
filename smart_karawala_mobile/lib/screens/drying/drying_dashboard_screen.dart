import 'dart:async';

import 'package:flutter/material.dart';
import '../../widgets/drying/live_chart.dart';
import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';

import '../../widgets/drying/sensor_card.dart';
import '../../widgets/drying/status_tile.dart';
import '../../widgets/drying/progress_card.dart';

class DryingDashboardScreen extends StatefulWidget {
  const DryingDashboardScreen({super.key});

  @override
  State<DryingDashboardScreen> createState() =>
      _DryingDashboardScreenState();
}

class _DryingDashboardScreenState
    extends State<DryingDashboardScreen> {

  SensorModel? sensor;

  bool loading = true;

  Timer? timer;
  List<double> tempHistory = [];
  List<double> humidityHistory = [];

  @override
  void initState() {
    super.initState();

    loadSensor();

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadSensor(),
    );
  }

 Future<void> loadSensor() async {
  try {
    final data = await IotService.getLiveData();

    print("Temperature: ${data.temperature}");
    print("Humidity: ${data.humidity}");

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

  } catch (e, stackTrace) {

    print("ERROR: $e");
    print(stackTrace);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }
}
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffEAF7FF),

      

      body: loading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : sensor == null
        ? const Center(
            child: Text("No Sensor Data"),
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu),
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

                  /// Device Status Card
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
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Row(
                          children: const [

                            CircleAvatar(
                              radius: 6,
                              backgroundColor: Colors.green,
                            ),

                            SizedBox(width: 10),

                            Text(
                              "Device Online",
                              style: TextStyle(
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

                  const SizedBox(height: 20),

                  /// Sensor Cards
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
      value: "${sensor!.temperature} °C",
      subtitle: "Target : 50°C",
      color: Colors.red,
    ),

    SensorCard(
      icon: Icons.water_drop,
      title: "Humidity",
      value: "${sensor!.humidity} %",
      subtitle: "Target : 40%",
      color: Colors.green,
    ),

    SensorCard(
      icon: Icons.scale,
      title: "Weight",
      value: "${sensor!.weight} kg",
      subtitle: "Live Weight",
      color: Colors.deepPurple,
    ),

    ProgressCard(
      progress: 62,
    ),
  ],
),

const SizedBox(height: 25),

LiveChart(
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
                    status: sensor!.heater,
                  ),

                  const SizedBox(height: 10),

                  StatusTile(
                    icon: Icons.air,
                    title: "Fan",
                    status: sensor!.fan,
                  ),

                  const SizedBox(height: 10),

                  StatusTile(
                    icon: Icons.lightbulb,
                    title: "Light",
                    status: sensor!.light,
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 25),

Center(
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
          ),
    );
  }
}