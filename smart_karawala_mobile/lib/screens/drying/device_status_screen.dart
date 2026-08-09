import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';

class DeviceStatusScreen extends StatefulWidget {
  const DeviceStatusScreen({super.key});

  @override
  State<DeviceStatusScreen> createState() =>
      _DeviceStatusScreenState();
}

class _DeviceStatusScreenState
    extends State<DeviceStatusScreen> {

  SensorModel? sensor;

  bool loading = true;
  bool connected = false;

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

  // ============================================================
  // LOAD SENSOR DATA
  // ============================================================

  Future<void> loadData() async {
    try {
      final data = await IotService.getLiveData();

      if (!mounted) return;

      setState(() {
        sensor = data;
        loading = false;
        connected = true;
      });

    } catch (e) {

      debugPrint("Device Status Error: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
        connected = false;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // STATUS TILE
  // ============================================================

  Widget statusTile({
    required IconData icon,
    required String title,
    required bool status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: ListTile(

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 5,
        ),

        leading: Container(
          width: 45,
          height: 45,

          decoration: BoxDecoration(
            color: status
                ? Colors.green.withOpacity(0.12)
                : Colors.red.withOpacity(0.12),

            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,
            color: status
                ? Colors.green
                : Colors.red,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        subtitle: Text(
          status
              ? "Currently Running"
              : "Currently Stopped",

          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 7,
          ),

          decoration: BoxDecoration(
            color: status
                ? Colors.green.shade100
                : Colors.red.shade100,

            borderRadius: BorderRadius.circular(20),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 8,
                height: 8,

                decoration: BoxDecoration(
                  color: status
                      ? Colors.green
                      : Colors.red,

                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                status ? "ON" : "OFF",

                style: TextStyle(
                  color: status
                      ? Colors.green
                      : Colors.red,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SENSOR INFORMATION TILE
  // ============================================================

  Widget sensorInfoTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return ListTile(

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 4,
      ),

      leading: Container(
        width: 42,
        height: 42,

        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),

        child: Icon(
          icon,
          color: color,
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),

      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // DEVICE CONNECTION CARD
  // ============================================================

  Widget deviceConnectionCard() {
    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: connected
                  ? Colors.green.withOpacity(0.12)
                  : Colors.red.withOpacity(0.12),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              Icons.memory,
              size: 30,
              color: connected
                  ? Colors.green
                  : Colors.red,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "Arduino Nano",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  connected
                      ? "Connected to IoT system"
                      : "Connection unavailable",

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),

            decoration: BoxDecoration(
              color: connected
                  ? Colors.green.shade100
                  : Colors.red.shade100,

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              connected ? "ONLINE" : "OFFLINE",

              style: TextStyle(
                color: connected
                    ? Colors.green
                    : Colors.red,

                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffEAF7FF),

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                15,
                20,
                10,
              ),

              child: Row(
                children: [

                  Container(
                    width: 42,
                    height: 42,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                      ),

                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const Spacer(),

                  Image.asset(
                    "assets/images/logo.png",
                    width: 70,
                  ),
                ],
              ),
            ),

            // ==================================================
            // TITLE
            // ==================================================

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "IoT Device Status",

                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff234D73),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Monitor your drying device and sensors",

                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child: loading

                  ? const Center(
                      child: CircularProgressIndicator(),
                    )

                  : RefreshIndicator(
                      onRefresh: loadData,

                      child: SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),

                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          25,
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            // =================================
                            // DEVICE CONNECTION
                            // =================================

                            deviceConnectionCard(),

                            const SizedBox(height: 25),

                            // =================================
                            // IF NO SENSOR DATA
                            // =================================

                            if (sensor == null)
                              Container(
                                width: double.infinity,

                                padding:
                                    const EdgeInsets.all(25),

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(18),
                                ),

                                child: Column(
                                  children: [

                                    const Icon(
                                      Icons.cloud_off,
                                      size: 55,
                                      color: Colors.grey,
                                    ),

                                    const SizedBox(height: 15),

                                    const Text(
                                      "No Sensor Data",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      "Unable to receive data from the Arduino.",
                                      textAlign:
                                          TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    ElevatedButton.icon(
                                      onPressed: loadData,

                                      icon: const Icon(
                                        Icons.refresh,
                                      ),

                                      label:
                                          const Text("Retry"),

                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            const Color(
                                                0xff234D73),

                                        foregroundColor:
                                            Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )

                            // =================================
                            // SENSOR DATA
                            // =================================

                            else ...[

                              const Text(
                                "Device Controls",

                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xff234D73),
                                ),
                              ),

                              const SizedBox(height: 12),

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

                              const SizedBox(height: 15),

                              const Text(
                                "Sensor Information",

                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xff234D73),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Container(
                                width: double.infinity,

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                          18),

                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 7,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),

                                child: Column(
                                  children: [

                                    sensorInfoTile(
                                      icon:
                                          Icons.thermostat,
                                      color: Colors.red,
                                      title:
                                          "Temperature",
                                      value:
                                          "${sensor!.temperature} °C",
                                    ),

                                    const Divider(
                                      height: 1,
                                    ),

                                    sensorInfoTile(
                                      icon:
                                          Icons.water_drop,
                                      color: Colors.blue,
                                      title:
                                          "Humidity",
                                      value:
                                          "${sensor!.humidity} %",
                                    ),

                                    const Divider(
                                      height: 1,
                                    ),

                                    sensorInfoTile(
                                      icon:
                                          Icons.scale,
                                      color:
                                          Colors.deepPurple,
                                      title:
                                          "Weight",
                                      value:
                                          "${sensor!.weight} kg",
                                    ),

                                    const Divider(
                                      height: 1,
                                    ),

                                    sensorInfoTile(
                                      icon:
                                          Icons.device_thermostat,
                                      color:
                                          Colors.orange,
                                      title:
                                          "DS Temperature",
                                      value:
                                          "${sensor!.dsTemperature} °C",
                                    ),

                                    const Divider(
                                      height: 1,
                                    ),

                                    sensorInfoTile(
                                      icon:
                                          Icons.air,
                                      color:
                                          Colors.teal,
                                      title: "Gas",
                                      value:
                                          "${sensor!.gas}",
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              // =================================
                              // RAW WEIGHT
                              // =================================

                              Container(
                                width: double.infinity,

                                padding:
                                    const EdgeInsets.all(18),

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(18),

                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 7,
                                    ),
                                  ],
                                ),

                                child: Row(
                                  children: [

                                    const Icon(
                                      Icons.monitor_weight,
                                      color:
                                          Colors.deepPurple,
                                      size: 30,
                                    ),

                                    const SizedBox(width: 15),

                                    const Expanded(
                                      child: Text(
                                        "Load Cell Raw Value",
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      "${sensor!.rawWeight}",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 25),

                            // =================================
                            // REFRESH BUTTON
                            // =================================

                            SizedBox(
                              width: double.infinity,

                              child:
                                  ElevatedButton.icon(
                                onPressed: loadData,

                                icon: const Icon(
                                  Icons.refresh,
                                ),

                                label: const Text(
                                  "Refresh Device Data",
                                ),

                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                      const Color(
                                          0xff234D73),

                                  foregroundColor:
                                      Colors.white,

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 15,
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}