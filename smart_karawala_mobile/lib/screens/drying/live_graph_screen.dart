import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';
import '../../widgets/drying/live_chart.dart';

class LiveGraphScreen extends StatefulWidget {
  const LiveGraphScreen({super.key});

  @override
  State<LiveGraphScreen> createState() => _LiveGraphScreenState();
}

class _LiveGraphScreenState extends State<LiveGraphScreen> {
  Timer? timer;

  bool loading = true;

  SensorModel? sensor;

  List<double> tempHistory = [];
  List<double> humidityHistory = [];
  List<double> weightHistory = [];

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

      if (!mounted) return;

      setState(() {
        sensor = data;
        loading = false;

        tempHistory.add(data.temperature);
        humidityHistory.add(data.humidity);
        weightHistory.add(data.weight);

        if (tempHistory.length > 30) {
          tempHistory.removeAt(0);
        }

        if (humidityHistory.length > 30) {
          humidityHistory.removeAt(0);
        }

        if (weightHistory.length > 30) {
          weightHistory.removeAt(0);
        }
      });
    } catch (e) {
      debugPrint(e.toString());

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

      appBar: AppBar(
        backgroundColor: const Color(0xff234D73),
        foregroundColor: Colors.white,
        title: const Text("Live Sensor Graphs"),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
  "Temperature History",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xff234D73),
  ),
),

const SizedBox(height: 15),

Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child:LiveChart(
  title: "Temperature History",
  temperatures: tempHistory,
),
  ),
),

const SizedBox(height: 30),

const Text(
  "Humidity History",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xff234D73),
  ),
),

const SizedBox(height: 15),

Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: LiveChart(
  title: "Humidity History",
  humidities: humidityHistory,
),
  ),
),



const SizedBox(height: 30),

const Text(
  "Weight History",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xff234D73),
  ),
),

const SizedBox(height: 15),

Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: LiveChart(
      title: "Weight History",
      weights: weightHistory,
    ),
  ),
),

const SizedBox(height: 30),

const Text(
  "Current Sensor Values",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Color(0xff234D73),
  ),
),

const SizedBox(height: 15),

Card(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [

        ListTile(
          leading: const Icon(
            Icons.thermostat,
            color: Colors.red,
          ),
          title: const Text("Temperature"),
          trailing: Text(
            "${sensor?.temperature ?? 0} °C",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(
            Icons.water_drop,
            color: Colors.blue,
          ),
          title: const Text("Humidity"),
          trailing: Text(
            "${sensor?.humidity ?? 0} %",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(
            Icons.scale,
            color: Colors.deepPurple,
          ),
          title: const Text("Weight"),
          trailing: Text(
            "${sensor?.weight ?? 0} kg",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 30),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: loadSensor,
    icon: const Icon(Icons.refresh),
    label: const Text("Refresh Now"),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 15),
      backgroundColor: const Color(0xff234D73),
      foregroundColor: Colors.white,
    ),
  ),
),

const SizedBox(height: 20),

const Center(
  child: Text(
    "Powered by Smart Karawala",
    style: TextStyle(
      color: Colors.grey,
    ),
  ),
),
                ],
              ),
            ),
    );
  }
  
  
}