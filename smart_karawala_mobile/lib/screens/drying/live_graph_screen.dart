import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';
import '../../widgets/drying/live_chart.dart';

class LiveGraphScreen
    extends StatefulWidget {
  const LiveGraphScreen({
    super.key,
  });

  @override
  State<LiveGraphScreen> createState() =>
      _LiveGraphScreenState();
}

class _LiveGraphScreenState
    extends State<LiveGraphScreen> {

  Timer? timer;

  SensorModel? sensor;

  bool loading = true;

  List<double> temperatures = [];
  List<double> humidities = [];
  List<double> weights = [];

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
      final data =
          await IotService.getLiveData();

      if (!mounted) return;

      setState(() {
        sensor = data;
        loading = false;

        temperatures.add(
          data.temperature,
        );

        humidities.add(
          data.humidity,
        );

        weights.add(
          data.weight,
        );

        if (temperatures.length > 30) {
          temperatures.removeAt(0);
        }

        if (humidities.length > 30) {
          humidities.removeAt(0);
        }

        if (weights.length > 30) {
          weights.removeAt(0);
        }
      });
    } catch (e) {
      debugPrint(
        "Graph error: $e",
      );

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
      backgroundColor:
          const Color(0xffEAF7FF),

      appBar: AppBar(
        title:
            const Text("Live Sensor Graphs"),
        backgroundColor:
            const Color(0xff234D73),
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Temperature",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xff234D73),
                    ),
                  ),

                  const SizedBox(height: 12),

                  LiveChart(
                    title:
                        "Temperature History",
                    values:
                        temperatures,
                    unit: "°C",
                    color: Colors.red,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Humidity",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xff234D73),
                    ),
                  ),

                  const SizedBox(height: 12),

                  LiveChart(
                    title:
                        "Humidity History",
                    values:
                        humidities,
                    unit: "%",
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Fish Weight",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xff234D73),
                    ),
                  ),

                  const SizedBox(height: 12),

                  LiveChart(
                    title:
                        "Weight History",
                    values:
                        weights,
                    unit: "kg",
                    color:
                        Colors.deepPurple,
                  ),

                  const SizedBox(height: 25),

                  if (sensor != null)
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(16),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              "Current Weight",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            Text(
                              "${sensor!.weight.toStringAsFixed(3)} kg",
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color: Colors
                                    .deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          loadSensor,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                        "Refresh Now",
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xff234D73,
                        ),
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 15,
                        ),
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
