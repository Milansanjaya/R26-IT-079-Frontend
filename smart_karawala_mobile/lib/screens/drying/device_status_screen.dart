import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';

class DeviceStatusScreen
    extends StatefulWidget {
  const DeviceStatusScreen({
    super.key,
  });

  @override
  State<DeviceStatusScreen> createState() =>
      _DeviceStatusScreenState();
}

class _DeviceStatusScreenState
    extends State<DeviceStatusScreen> {

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
      final data =
          await IotService.getLiveData();

      if (!mounted) return;

      setState(() {
        sensor = data;
        loading = false;
      });
    } catch (e) {
      debugPrint(
        "Device status error: $e",
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

  Widget statusTile({
    required IconData icon,
    required String title,
    required bool status,
  }) {
    return Card(
      elevation: 2,
      margin:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: status
              ? Colors.green
              : Colors.red,
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: status
                ? Colors.green
                    .withOpacity(.12)
                : Colors.red
                    .withOpacity(.12),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Text(
            status ? "ON" : "OFF",
            style: TextStyle(
              color: status
                  ? Colors.green
                  : Colors.red,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffEAF7FF),

      appBar: AppBar(
        title:
            const Text("Device Status"),
        backgroundColor:
            const Color(0xff234D73),
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : sensor == null
              ? const Center(
                  child: Text(
                    "No Device Data",
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    children: [

                      // DEVICE
                      Card(
                        elevation: 3,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),
                        child: ListTile(
                          leading:
                              CircleAvatar(
                            backgroundColor:
                                sensor!.online
                                    ? Colors.green
                                        .withOpacity(
                                        .12,
                                      )
                                    : Colors.red
                                        .withOpacity(
                                        .12,
                                      ),
                            child: Icon(
                              Icons.memory,
                              color: sensor!
                                      .online
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                            sensor!.deviceId,
                          ),
                          subtitle:
                              const Text(
                            "Arduino Connection",
                          ),
                          trailing:
                              Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration:
                                BoxDecoration(
                              color: sensor!
                                      .online
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              sensor!.online
                                  ? "ONLINE"
                                  : "OFFLINE",
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // DEVICE CONTROLS STATUS
                      statusTile(
                        icon: Icons
                            .local_fire_department,
                        title: "Heater",
                        status:
                            sensor!.heater,
                      ),

                      statusTile(
                        icon: Icons.air,
                        title: "Fan",
                        status:
                            sensor!.fan,
                      ),

                      statusTile(
                        icon:
                            Icons.lightbulb,
                        title: "Light",
                        status:
                            sensor!.light,
                      ),

                      const SizedBox(height: 20),

                      // SENSOR VALUES
                      Card(
                        elevation: 3,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),
                        child: Column(
                          children: [

                            ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .thermostat,
                                color:
                                    Colors.red,
                              ),
                              title:
                                  const Text(
                                "Temperature",
                              ),
                              trailing:
                                  Text(
                                "${sensor!.temperature.toStringAsFixed(1)} °C",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            const Divider(
                              height: 1,
                            ),

                            ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .water_drop,
                                color:
                                    Colors.blue,
                              ),
                              title:
                                  const Text(
                                "Humidity",
                              ),
                              trailing:
                                  Text(
                                "${sensor!.humidity.toStringAsFixed(1)} %",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            const Divider(
                              height: 1,
                            ),

                            ListTile(
                              leading:
                                  const Icon(
                                Icons.scale,
                                color: Colors
                                    .deepPurple,
                              ),
                              title:
                                  const Text(
                                "Current Weight",
                              ),
                              trailing:
                                  Text(
                                "${sensor!.weight.toStringAsFixed(2)} kg",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            const Divider(
                              height: 1,
                            ),

                            ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .thermostat_auto,
                              ),
                              title:
                                  const Text(
                                "DS Temperature",
                              ),
                              trailing:
                                  Text(
                               "${sensor!.dsTemperature?.toStringAsFixed(1) ?? '--'} °C",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            const Divider(
                              height: 1,
                            ),

                            ListTile(
                              leading:
                                  const Icon(
                                Icons
                                    .local_gas_station,
                              ),
                              title:
                                  const Text(
                                "Gas",
                              ),
                              trailing:
                                  Text(
                                "${sensor!.gas}",
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              loadData,
                          icon:
                              const Icon(
                            Icons.refresh,
                          ),
                          label:
                              const Text(
                            "Refresh",
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