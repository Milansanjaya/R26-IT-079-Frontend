import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';

class DeviceStatusScreen extends StatefulWidget {
  const DeviceStatusScreen({super.key});

  @override
  State<DeviceStatusScreen> createState() => _DeviceStatusScreenState();
}

class _DeviceStatusScreenState extends State<DeviceStatusScreen> {
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

  Widget statusTile({
    required IconData icon,
    required String title,
    required bool status,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: status ? Colors.green : Colors.red,
        ),
        title: Text(title),
        trailing: Chip(
          label: Text(
            status ? "ON" : "OFF",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor:
              status ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      appBar: AppBar(
        title: const Text("Device Status"),
        backgroundColor: const Color(0xff234D73),
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(
                        Icons.memory,
                        color: Colors.green,
                      ),
                      title: const Text("Arduino"),
                      subtitle:
                          const Text("Connection Status"),
                      trailing: const Chip(
                        label: Text(
                          "ONLINE",
                          style: TextStyle(
                              color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  statusTile(
                    icon: Icons.local_fire_department,
                    title: "Heater",
                    status: sensor!.heater,
                  ),

                  statusTile(
                    icon: Icons.air,
                    title: "Fan",
                    status: sensor!.fan,
                  ),

                  statusTile(
                    icon: Icons.lightbulb,
                    title: "Light",
                    status: sensor!.light,
                  ),

                  const SizedBox(height: 25),

                  Card(
                    elevation: 3,
                    child: Column(
                      children: [

                        ListTile(
                          leading: const Icon(
                              Icons.thermostat),
                          title:
                              const Text("Temperature"),
                          trailing: Text(
                            "${sensor!.temperature} °C",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const Divider(height: 1),

                        ListTile(
                          leading: const Icon(
                              Icons.water_drop),
                          title:
                              const Text("Humidity"),
                          trailing: Text(
                            "${sensor!.humidity} %",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const Divider(height: 1),

                        ListTile(
                          leading:
                              const Icon(Icons.scale),
                          title: const Text("Weight"),
                          trailing: Text(
                            "${sensor!.weight} kg",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
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
                      onPressed: loadData,
                      icon:
                          const Icon(Icons.refresh),
                      label:
                          const Text("Refresh"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xff234D73),
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Powered by Smart Karawala",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}