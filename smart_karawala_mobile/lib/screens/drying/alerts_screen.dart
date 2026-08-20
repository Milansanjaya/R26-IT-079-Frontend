import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/iot_service.dart';
import '../../models/sensor_model.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  SensorModel? sensor;
  bool loading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadData();

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadData(),
    );
  }

  Future<void> loadData() async {
    try {
      final data = await IotService.getLiveData();

      if (!mounted) return;

      setState(() {
        sensor = data;
        loading = false;
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

  Widget buildAlert({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final alerts = <Widget>[];

    if (sensor != null) {
      if (sensor!.temperature > 50) {
        alerts.add(
          buildAlert(
            icon: Icons.thermostat,
            color: Colors.red,
            title: "High Temperature",
            message:
                "Current temperature is ${sensor!.temperature} °C",
          ),
        );
      }

      if (sensor!.humidity > 40) {
        alerts.add(
          buildAlert(
            icon: Icons.water_drop,
            color: Colors.orange,
            title: "High Humidity",
            message:
                "Current humidity is ${sensor!.humidity} %",
          ),
        );
      }

     if (
  sensor!.targetGas != null &&
  sensor!.gas != null &&
  sensor!.gas! > sensor!.targetGas!
) {
  alerts.add(
    buildAlert(
      icon: Icons.warning,
      color: Colors.deepOrange,
      title: "Gas Level Warning",
      message:
          "Gas level is ${sensor!.gas!.toStringAsFixed(0)}. Target is ${sensor!.targetGas!.toStringAsFixed(0)}.",
    ),
  );
}

      if (alerts.isEmpty) {
        alerts.add(
          buildAlert(
            icon: Icons.check_circle,
            color: Colors.green,
            title: "System Normal",
            message: "No active alerts.",
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),
      appBar: AppBar(
        title: const Text("Alerts"),
        backgroundColor: const Color(0xff234D73),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "System Alerts",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ...alerts,

            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}