import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';

import '../../widgets/drying/sensor_card.dart';
import '../../widgets/drying/status_tile.dart';
import '../../widgets/drying/progress_card.dart';

import 'alerts_screen.dart';
import 'device_status_screen.dart';
import 'drying_control_screen.dart';
import 'live_graph_screen.dart';

class DryingDashboardScreen
    extends StatefulWidget {
  const DryingDashboardScreen({
    super.key,
  });

  @override
  State<DryingDashboardScreen> createState() =>
      _DryingDashboardScreenState();
}

class _DryingDashboardScreenState
    extends State<DryingDashboardScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  SensorModel? sensor;

  bool loading = true;

  Timer? timer;

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
      });
    } catch (e) {
      debugPrint(
        "Sensor error: $e",
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
      key: _scaffoldKey,
      backgroundColor:
          const Color(0xffEAF7FF),
      drawer: Drawer(
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
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text("Control"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DryingControlScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text("Live Graph"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveGraphScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.memory),
              title: const Text("Device Status"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceStatusScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Alerts"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlertsScreen(),
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
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : sensor == null
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No Sensor Data",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton.icon(
                        onPressed: loadSensor,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label: const Text(
                          "Try Again",
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        // ==================================================
                        // HEADER
                        // ==================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: Container(
                                height: 42,
                                width: 42,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu,
                                ),
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
                            fontSize: 36,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xff234D73),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // DEVICE CONNECTION
                        // ==================================================

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                            boxShadow:
                                const [
                              BoxShadow(
                                color:
                                    Colors.black12,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 6,
                                    backgroundColor:
                                        sensor!.online
                                            ? Colors
                                                .green
                                            : Colors
                                                .red,
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  Text(
                                    sensor!.online
                                        ? "Device Online"
                                        : "Device Offline",
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              ),

                              Text(
                                sensor!.deviceId,
                                style:
                                    const TextStyle(
                                  color: Colors.grey,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // SENSOR CARDS
                        // ==================================================

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.90,
                          children: [

                            SensorCard(
                              icon:
                                  Icons.thermostat,
                              title:
                                  "Temperature",
                              value:
                                  "${sensor!.temperature.toStringAsFixed(1)} °C",
                              subtitle:
                                  "Target: ${sensor!.targetTemperature.toStringAsFixed(0)} °C",
                              color:
                                  Colors.red,
                            ),

                            SensorCard(
                              icon:
                                  Icons.water_drop,
                              title:
                                  "Humidity",
                              value:
                                  "${sensor!.humidity.toStringAsFixed(1)} %",
                              subtitle:
                                  "Target: ${sensor!.targetHumidity.toStringAsFixed(0)} %",
                              color:
                                  Colors.green,
                            ),

                            SensorCard(
                              icon:
                                  Icons.scale,
                              title: "Weight",
                              value:
                                  "${sensor!.weight.toStringAsFixed(3)} kg",
                              subtitle:
                                  "Live Fish Weight",
                              color:
                                  Colors.deepPurple,
                            ),

                            ProgressCard(
                              progress:
                                  sensor!.progress,
                              currentWeight:
                                  sensor!.weight,
                              initialWeight:
                                  sensor!.initialWeight,
                              targetWeight:
                                  sensor!.targetWeight,
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // DRYING WEIGHT INFORMATION
                        // ==================================================

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(18),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                            boxShadow:
                                const [
                              BoxShadow(
                                color:
                                    Colors.black12,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              const Text(
                                "Drying Weight Information",
                                style:
                                    TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      Color(
                                    0xff234D73,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              _weightRow(
                                "Initial Weight",
                                sensor!
                                    .initialWeight,
                                Colors.blue,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _weightRow(
                                "Target Weight",
                                sensor!
                                    .targetWeight,
                                Colors.green,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              _weightRow(
                                "Current Weight",
                                sensor!.weight,
                                Colors
                                    .deepPurple,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  const Text(
                                    "Progress",
                                  ),

                                  Text(
                                    "${sensor!.progress.toStringAsFixed(0)}%",
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color:
                                          Colors
                                              .orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // DEVICE STATUS
                        // ==================================================

                        const Text(
                          "Device Status",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xff234D73),
                          ),
                        ),

                        const SizedBox(height: 10),

                        StatusTile(
                          icon: Icons
                              .local_fire_department,
                          title: "Heater",
                          status:
                              sensor!.heater,
                        ),

                        StatusTile(
                          icon: Icons.air,
                          title: "Fan",
                          status:
                              sensor!.fan,
                        ),

                        StatusTile(
                          icon:
                              Icons.lightbulb,
                          title: "Light",
                          status:
                              sensor!.light,
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // REFRESH
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          child:
                              ElevatedButton.icon(
                            onPressed:
                                loadSensor,
                            icon: const Icon(
                              Icons.refresh,
                            ),
                            label: const Text(
                              "Refresh Sensor Data",
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

                        const SizedBox(height: 25),

                        const Center(
                          child: Text(
                            "Powered by Smart Karawala",
                            style: TextStyle(
                              color:
                                  Colors.grey,
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

  Widget _weightRow(
    String title,
    double value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(title),

        Text(
          "${value.toStringAsFixed(3)} kg",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
