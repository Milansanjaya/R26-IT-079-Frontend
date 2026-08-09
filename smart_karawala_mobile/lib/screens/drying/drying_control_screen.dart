import 'package:flutter/material.dart';

import '../../services/iot_service.dart';

class DryingControlScreen extends StatefulWidget {
  const DryingControlScreen({super.key});

  @override
  State<DryingControlScreen> createState() =>
      _DryingControlScreenState();
}

class _DryingControlScreenState extends State<DryingControlScreen> {
  bool autoMode = true;

  bool heater = false;
  bool fan = false;
  bool light = false;

  final TextEditingController tempController =
      TextEditingController(text: "50");

  final TextEditingController humidityController =
      TextEditingController(text: "40");

  @override
  void dispose() {
    tempController.dispose();
    humidityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// Header
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back),
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
                "Drying Control",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff234D73),
                ),
              ),

              const SizedBox(height: 30),

              /// Operation Mode

              const Text(
                "Operation Mode",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            autoMode
                                ? Colors.blue
                                : Colors.white,
                        foregroundColor:
                            autoMode
                                ? Colors.white
                                : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          autoMode = true;
                        });
                      },
                      child: const Text("AUTO"),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !autoMode
                                ? Colors.blue
                                : Colors.white,
                        foregroundColor:
                            !autoMode
                                ? Colors.white
                                : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          autoMode = false;
                        });
                      },
                      child: const Text("MANUAL"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Target Conditions

              const Text(
                "Target Conditions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: tempController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Temperature (°C)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: humidityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Humidity (%)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                            Text("Settings Saved"),
                      ),
                    );
                  },
                  child:
                      const Text("Save Settings"),
                ),
              ),

              const SizedBox(height: 30),

              /// Manual Controls

              const Text(
                "Manual Controls",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              buildSwitch(
                "Heater",
                heater,
                Icons.local_fire_department,
                (value) async {

                  try {

                    final response =
                        await IotService.sendCommand(
                      value
                          ? "heater_on"
                          : "heater_off",
                    );

                    if (response["success"] ==
                        true) {
                      setState(() {
                        heater = value;
                      });
                    }

                  } catch (e) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content:
                            Text(e.toString()),
                      ),
                    );

                  }
                },
              ),

              buildSwitch(
                "Fan",
                fan,
                Icons.air,
                (value) async {

                  try {

                    final response =
                        await IotService.sendCommand(
                      value
                          ? "fan_on"
                          : "fan_off",
                    );

                    if (response["success"] ==
                        true) {
                      setState(() {
                        fan = value;
                      });
                    }

                  } catch (e) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content:
                            Text(e.toString()),
                      ),
                    );

                  }
                },
              ),

              buildSwitch(
                "Light",
                light,
                Icons.lightbulb,
                (value) async {

                  try {

                    final response =
                        await IotService.sendCommand(
                      value
                          ? "light_on"
                          : "light_off",
                    );

                    if (response["success"] ==
                        true) {
                      setState(() {
                        light = value;
                      });
                    }

                  } catch (e) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content:
                            Text(e.toString()),
                      ),
                    );

                  }
                },
              ),

              const SizedBox(height: 30),

              /// Buttons

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Start command not implemented yet"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label:
                      const Text("Start Drying"),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Stop command not implemented yet"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.stop),
                  label:
                      const Text("Stop Drying"),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.orange,
                  ),
                  onPressed: () async {

                    try {

                      final response =
                          await IotService
                              .sendCommand(
                        "tare",
                      );

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            response["message"] ??
                                "Success",
                          ),
                        ),
                      );

                    } catch (e) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content:
                              Text(e.toString()),
                        ),
                      );

                    }
                  },
                  icon:
                      const Icon(Icons.refresh),
                  label: const Text("Reset"),
                ),
              ),

              const SizedBox(height: 30),

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
      ),
    );
  }

  Widget buildSwitch(
    String title,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}