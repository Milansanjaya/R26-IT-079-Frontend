import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/sensor_model.dart';
import '../../services/iot_service.dart';

class DryingControlScreen extends StatefulWidget {
  const DryingControlScreen({
    super.key,
  });

  @override
  State<DryingControlScreen> createState() =>
      _DryingControlScreenState();
}

class _DryingControlScreenState
    extends State<DryingControlScreen> {
  // ============================================================
  // SENSOR
  // ============================================================

  SensorModel? sensor;

  Timer? timer;

  bool loading = true;

  // ============================================================
  // OPERATION MODE
  // ============================================================

  bool autoMode = true;

  // ============================================================
  // DRYING STATUS
  // ============================================================

  bool dryingRunning = false;

  bool dryingStopped = true;

  String? dryingMode;

  // ============================================================
  // COMMAND STATUS
  // ============================================================

  bool sendingCommand = false;

  bool startSending = false;
  bool stopSending = false;
  bool tareSending = false;

  bool heaterSending = false;
  bool fanSending = false;
  bool lightSending = false;

  // ============================================================
  // LOCAL DEVICE STATES
  //
  // These are used so the UI changes immediately after pressing
  // the switch instead of waiting for the Arduino refresh.
  // ============================================================

  bool heaterOn = false;
  bool fanOn = false;
  bool lightOn = false;

  // ============================================================
  // TARGET CONTROLLERS
  // ============================================================

  final TextEditingController temperatureController =
      TextEditingController();

  final TextEditingController humidityController =
      TextEditingController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadSensor();

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        loadSensor();
      },
    );
  }

  // ============================================================
  // LOAD SENSOR
  // ============================================================

  Future<void> loadSensor() async {
    try {
      final data = await IotService.getLiveData();

      if (!mounted) {
        return;
      }

      setState(() {
        sensor = data;
        loading = false;

        // --------------------------------------------------------
        // Get current device states from Arduino
        //
        // Don't overwrite the UI while a command is being sent.
        // --------------------------------------------------------

        if (!heaterSending) {
          heaterOn = data.heater;
        }

        if (!fanSending) {
          fanOn = data.fan;
        }

        if (!lightSending) {
          lightOn = data.light;
        }

        // --------------------------------------------------------
        // AUTO MODE
        //
        // Target values are supplied by backend/friend calculation.
        // User cannot edit them.
        // --------------------------------------------------------

        if (autoMode) {
          temperatureController.text =
              data.targetTemperature.toStringAsFixed(1);

          humidityController.text =
              data.targetHumidity.toStringAsFixed(1);
        }
      });
    } catch (e) {
      debugPrint(
        "Sensor loading error: $e",
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });
    }
  }

  // ============================================================
  // CHANGE AUTO / MANUAL MODE
  // ============================================================

  void changeMode(bool newAutoMode) {
    // Never allow mode change while drying.
    if (dryingRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Stop the current drying process before changing mode.",
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    setState(() {
      autoMode = newAutoMode;
    });

    // ----------------------------------------------------------
    // AUTO
    // ----------------------------------------------------------

    if (newAutoMode && sensor != null) {
      temperatureController.text =
          sensor!.targetTemperature.toStringAsFixed(1);

      humidityController.text =
          sensor!.targetHumidity.toStringAsFixed(1);
    }

    // ----------------------------------------------------------
    // MANUAL
    // ----------------------------------------------------------

    if (!newAutoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Manual mode selected. Target values can be edited.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ============================================================
  // DEVICE SENDING CHECK
  // ============================================================

  bool isDeviceSending(String title) {
    switch (title) {
      case "Heater":
        return heaterSending;

      case "Fan":
        return fanSending;

      case "Light":
        return lightSending;

      default:
        return false;
    }
  }

  // ============================================================
  // SET DEVICE SENDING
  // ============================================================

  void setDeviceSending(
    String title,
    bool value,
  ) {
    switch (title) {
      case "Heater":
        heaterSending = value;
        break;

      case "Fan":
        fanSending = value;
        break;

      case "Light":
        lightSending = value;
        break;
    }
  }

  // ============================================================
  // GET DEVICE STATE
  // ============================================================

  bool getDeviceState(String title) {
    switch (title) {
      case "Heater":
        return heaterOn;

      case "Fan":
        return fanOn;

      case "Light":
        return lightOn;

      default:
        return false;
    }
  }

  // ============================================================
  // SET DEVICE STATE
  // ============================================================

  void setDeviceState(
    String title,
    bool value,
  ) {
    switch (title) {
      case "Heater":
        heaterOn = value;
        break;

      case "Fan":
        fanOn = value;
        break;

      case "Light":
        lightOn = value;
        break;
    }
  }

  // ============================================================
  // MANUAL DEVICE CONTROL
  // ============================================================

  Future<void> changeDevice(
    String title,
    bool newValue,
    String onCommand,
    String offCommand,
  ) async {
    // ----------------------------------------------------------
    // AUTO MODE
    // ----------------------------------------------------------

    if (autoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Devices are controlled automatically in AUTO mode.",
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // MANUAL DRYING MUST BE RUNNING
    // ----------------------------------------------------------

    if (!dryingRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Start MANUAL drying first.",
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // PREVENT DUPLICATE COMMAND
    // ----------------------------------------------------------

    if (isDeviceSending(title)) {
      return;
    }

    final bool oldValue =
        getDeviceState(title);

    // ----------------------------------------------------------
    // CHANGE UI IMMEDIATELY
    // ----------------------------------------------------------

    setState(() {
      setDeviceState(
        title,
        newValue,
      );

      setDeviceSending(
        title,
        true,
      );
    });

    final String command =
        newValue
            ? onCommand
            : offCommand;

    try {
      debugPrint(
        "Sending device command: $command",
      );

      final response =
          await IotService.sendCommand(
        command,
      );

      debugPrint(
        "Device response: $response",
      );

      if (!mounted) {
        return;
      }

      final bool success =
          response["success"] == true;

      if (!success) {
        // Revert UI if backend failed.
        setState(() {
          setDeviceState(
            title,
            oldValue,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"]?.toString() ??
                  "Device command failed.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "Device command error: $e",
      );

      if (!mounted) {
        return;
      }

      // Revert UI.
      setState(() {
        setDeviceState(
          title,
          oldValue,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Device command failed.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          setDeviceSending(
            title,
            false,
          );
        });
      }
    }
  }

  // ============================================================
  // START DRYING
  // ============================================================

  Future<void> startDrying() async {
    // ----------------------------------------------------------
    // PREVENT DOUBLE START
    // ----------------------------------------------------------

    if (sendingCommand ||
        startSending ||
        dryingRunning) {
      return;
    }

    // ----------------------------------------------------------
    // SET LOADING IMMEDIATELY
    // ----------------------------------------------------------

    setState(() {
      sendingCommand = true;
      startSending = true;
    });

    try {
      final String command =
          autoMode
              ? "start_auto_drying"
              : "start_manual_drying";

      debugPrint(
        "====================================",
      );

      debugPrint(
        "START DRYING",
      );

      debugPrint(
        "MODE: ${autoMode ? "AUTO" : "MANUAL"}",
      );

      debugPrint(
        "COMMAND: $command",
      );

      debugPrint(
        "====================================",
      );

      final response =
          await IotService.sendCommand(
        command,
      );

      debugPrint(
        "START RESPONSE: $response",
      );

      if (!mounted) {
        return;
      }

      final bool success =
          response["success"] == true;

      if (success) {
        setState(() {
          dryingRunning = true;
          dryingStopped = false;

          dryingMode =
              response["mode"]?.toString() ??
                  (autoMode
                      ? "AUTO"
                      : "MANUAL");
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              autoMode
                  ? "AUTO drying started successfully."
                  : "MANUAL drying started successfully.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Get latest Arduino state.
        await loadSensor();
        // If manual mode was started, ensure heater and light turn ON immediately.
        if (!autoMode) {
          try {
            // Use changeDevice helper to keep UI state and sending flags consistent.
            await changeDevice(
              "Heater",
              true,
              "heater_on",
              "heater_off",
            );

            await changeDevice(
              "Light",
              true,
              "light_on",
              "light_off",
            );
          } catch (e) {
            // Non-fatal; user will see device command errors through changeDevice.
            debugPrint("Post-start device commands failed: $e");
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"]?.toString() ??
                  "Unable to start drying.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "START DRYING ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Start drying failed: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sendingCommand = false;
          startSending = false;
        });
      }
    }
  }

  // ============================================================
  // STOP DRYING
  // ============================================================

  Future<void> stopDrying() async {
    if (sendingCommand ||
        stopSending) {
      return;
    }

    setState(() {
      sendingCommand = true;
      stopSending = true;
    });

    try {
      debugPrint(
        "STOPPING DRYING...",
      );

      final response =
          await IotService.sendCommand(
        "stop_drying",
      );

      debugPrint(
        "STOP RESPONSE: $response",
      );

      if (!mounted) {
        return;
      }

      final bool success =
          response["success"] == true;

      if (success) {
        setState(() {
          dryingRunning = false;
          dryingStopped = true;
          dryingMode = null;

          // Local device states reset.
          heaterOn = false;
          fanOn = false;
          lightOn = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Drying stopped successfully.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        // Ensure actuators are explicitly turned OFF in case backend didn't update them.
        try {
          await IotService.sendCommand("heater_off");
        } catch (_) {}

        try {
          await IotService.sendCommand("fan_off");
        } catch (_) {}

        try {
          await IotService.sendCommand("light_off");
        } catch (_) {}

        await loadSensor();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"]?.toString() ??
                  "Unable to stop drying.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "STOP DRYING ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Stop drying failed: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sendingCommand = false;
          stopSending = false;
        });
      }
    }
  }

  // ============================================================
  // TARE / RESET WEIGHT
  // ============================================================

  Future<void> tareWeight() async {
    if (tareSending) {
      return;
    }

    setState(() {
      tareSending = true;
    });

    try {
      debugPrint(
        "Sending tare command...",
      );

      final response =
          await IotService.sendCommand(
        "tare",
      );

      debugPrint(
        "TARE RESPONSE: $response",
      );

      if (!mounted) {
        return;
      }

      final bool success =
          response["success"] == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Weight reset successfully."
                : response["message"]?.toString() ??
                    "Tare failed.",
          ),
          backgroundColor:
              success
                  ? Colors.green
                  : Colors.red,
        ),
      );

      if (success) {
        await loadSensor();
      }
    } catch (e) {
      debugPrint(
        "TARE ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tare command failed.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          tareSending = false;
        });
      }
    }
  }

  // ============================================================
  // DEVICE SWITCH
  // ============================================================

  Widget deviceSwitch({
    required String title,
    required IconData icon,
    required bool value,
    required String onCommand,
    required String offCommand,
  }) {
    final bool sending =
        isDeviceSending(title);

    // ----------------------------------------------------------
    // IMPORTANT:
    //
    // AUTO:
    //   Device controls locked.
    //
    // MANUAL:
    //   Device controls available only while drying is running.
    // ----------------------------------------------------------

    final bool enabled =
        !autoMode &&
        dryingRunning &&
        !sending;

    return Card(
      elevation: 2,

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color:
              value
                  ? Colors.green
                  : Colors.grey,
          size: 30,
        ),

        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        subtitle: Text(
          sending
              ? "Sending command..."
              : value
                  ? "ON"
                  : "OFF",
        ),

        trailing: sending
            ? const SizedBox(
                width: 24,
                height: 24,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Switch(
                value: value,

                onChanged:
                    enabled
                        ? (newValue) {
                            changeDevice(
                              title,
                              newValue,
                              onCommand,
                              offCommand,
                            );
                          }
                        : null,
              ),
      ),
    );
  }

  // ============================================================
  // TARGET CONDITIONS CARD
  // ============================================================

  Widget targetConditionsCard() {
    final bool editable =
        !autoMode &&
        !dryingRunning;

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              const Text(
                "Target Conditions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xff234D73),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration:
                    BoxDecoration(
                  color: autoMode
                      ? Colors.blue.shade50
                      : Colors.orange.shade50,

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Text(
                  autoMode
                      ? "AUTO"
                      : "MANUAL",

                  style: TextStyle(
                    color: autoMode
                        ? Colors.blue
                        : Colors.orange,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          // ------------------------------------------------------
          // TEMPERATURE
          // ------------------------------------------------------

          TextField(
            controller:
                temperatureController,

            readOnly:
                !editable,

            keyboardType:
                const TextInputType
                    .numberWithOptions(
              decimal: true,
            ),

            decoration:
                InputDecoration(
              labelText:
                  "Target Temperature (°C)",

              prefixIcon:
                  const Icon(
                Icons.thermostat,
              ),

              suffixIcon:
                  autoMode
                      ? const Icon(
                          Icons.lock,
                        )
                      : null,

              filled: true,

              fillColor:
                  autoMode
                      ? Colors.grey.shade100
                      : Colors.white,

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          // ------------------------------------------------------
          // HUMIDITY
          // ------------------------------------------------------

          TextField(
            controller:
                humidityController,

            readOnly:
                !editable,

            keyboardType:
                const TextInputType
                    .numberWithOptions(
              decimal: true,
            ),

            decoration:
                InputDecoration(
              labelText:
                  "Target Humidity (%)",

              prefixIcon:
                  const Icon(
                Icons.water_drop,
              ),

              suffixIcon:
                  autoMode
                      ? const Icon(
                          Icons.lock,
                        )
                      : null,

              filled: true,

              fillColor:
                  autoMode
                      ? Colors.grey.shade100
                      : Colors.white,

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          // ------------------------------------------------------
          // INFORMATION
          // ------------------------------------------------------

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(
              12,
            ),

            decoration:
                BoxDecoration(
              color: autoMode
                  ? Colors.blue.shade50
                  : Colors.orange.shade50,

              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Icon(
                  autoMode
                      ? Icons.auto_mode
                      : Icons.edit,

                  color: autoMode
                      ? Colors.blue
                      : Colors.orange,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    autoMode
                        ? "AUTO mode uses target temperature and humidity from the drying calculation system. These values cannot be edited."
                        : dryingRunning
                            ? "Drying is running. Stop drying before changing target values."
                            : "MANUAL mode allows the administrator to edit the target values.",
                    style: TextStyle(
                      color: autoMode
                          ? Colors.blue
                          : Colors.orange,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT SENSOR VALUES
  // ============================================================

  Widget currentValuesCard() {
    if (sensor == null) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Current Sensor Values",
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xff234D73),
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          valueRow(
            icon: Icons.thermostat,
            title: "Temperature",
            value:
                "${sensor!.temperature.toStringAsFixed(1)} °C",
            color: Colors.red,
          ),

          valueRow(
            icon: Icons.water_drop,
            title: "Humidity",
            value:
                "${sensor!.humidity.toStringAsFixed(1)} %",
            color: Colors.blue,
          ),

          valueRow(
            icon: Icons.scale,
            title: "Current Weight",
            value:
                "${sensor!.weight.toStringAsFixed(2)} kg",
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VALUE ROW
  // ============================================================

  Widget valueRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              color: color,
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xffEAF7FF),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SafeArea(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
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

                            child:
                                const Icon(
                              Icons.arrow_back,
                            ),
                          ),
                        ),

                        Image.asset(
                          "assets/images/logo.png",
                          width: 70,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    const Text(
                      "Drying Control",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xff234D73),
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // DRYING STATUS
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets
                              .all(
                        16,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            dryingRunning
                                ? Colors.green
                                    .shade50
                                : Colors.red
                                    .shade50,

                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),

                        border: Border.all(
                          color:
                              dryingRunning
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            dryingRunning
                                ? Icons
                                    .play_circle
                                : Icons
                                    .stop_circle,

                            color:
                                dryingRunning
                                    ? Colors.green
                                    : Colors.red,

                            size: 32,
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  dryingRunning
                                      ? "Drying Running"
                                      : "Drying Stopped",

                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                Text(
                                  dryingRunning
                                      ? "${dryingMode ?? (autoMode ? "AUTO" : "MANUAL")} Mode"
                                      : autoMode
                                          ? "AUTO Mode"
                                          : "MANUAL Mode",

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // OPERATION MODE
                    // ==================================================

                    const Text(
                      "Operation Mode",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Row(
                      children: [
                        // AUTO
                        Expanded(
                          child:
                              ElevatedButton(
                            onPressed:
                                dryingRunning
                                    ? null
                                    : () {
                                        changeMode(
                                          true,
                                        );
                                      },

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  autoMode
                                      ? Colors.blue
                                      : Colors.white,

                              foregroundColor:
                                  autoMode
                                      ? Colors.white
                                      : Colors.black,
                            ),

                            child:
                                const Text(
                              "AUTO",
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        // MANUAL
                        Expanded(
                          child:
                              ElevatedButton(
                            onPressed:
                                dryingRunning
                                    ? null
                                    : () {
                                        changeMode(
                                          false,
                                        );
                                      },

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  !autoMode
                                      ? Colors.orange
                                      : Colors.white,

                              foregroundColor:
                                  !autoMode
                                      ? Colors.white
                                      : Colors.black,
                            ),

                            child:
                                const Text(
                              "MANUAL",
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // TARGET CONDITIONS
                    // ==================================================

                    targetConditionsCard(),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // CURRENT SENSOR VALUES
                    // ==================================================

                    currentValuesCard(),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // DEVICE CONTROLS
                    // ==================================================

                    const Text(
                      "Device Controls",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // HEATER
                    deviceSwitch(
                      title: "Heater",
                      icon:
                          Icons.local_fire_department,
                      value: heaterOn,
                      onCommand:
                          "heater_on",
                      offCommand:
                          "heater_off",
                    ),

                    // FAN
                    deviceSwitch(
                      title: "Fan",
                      icon: Icons.air,
                      value: fanOn,
                      onCommand:
                          "fan_on",
                      offCommand:
                          "fan_off",
                    ),

                    // LIGHT
                    deviceSwitch(
                      title: "Light",
                      icon:
                          Icons.lightbulb,
                      value: lightOn,
                      onCommand:
                          "light_on",
                      offCommand:
                          "light_off",
                    ),

                    // ==================================================
                    // AUTO LOCK MESSAGE
                    // ==================================================

                    if (autoMode)
                      Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .all(
                          14,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.blue
                                  .shade50,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),

                        child: const Row(
                          children: [
                            Icon(
                              Icons.lock,
                              color:
                                  Colors.blue,
                            ),

                            SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Text(
                                "AUTO mode controls the heater, exhaust fan and light automatically. Manual switches are locked.",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (!autoMode &&
                        !dryingRunning)
                      Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .all(
                          14,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.orange
                                  .shade50,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),

                        child: const Row(
                          children: [
                            Icon(
                              Icons.info,
                              color:
                                  Colors.orange,
                            ),

                            SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Text(
                                "Start manual drying before controlling the devices.",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==================================================
                    // START DRYING
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,

                      child:
                          ElevatedButton
                              .icon(
                        onPressed:
                            startSending ||
                                    dryingRunning
                                ? null
                                : startDrying,

                        icon:
                            startSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .play_arrow,
                                  ),

                        label: Text(
                          autoMode
                              ? "START AUTO DRYING"
                              : "START MANUAL DRYING",
                        ),

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.green,
                          foregroundColor:
                              Colors.white,

                          disabledBackgroundColor:
                              Colors.green
                                  .withOpacity(
                            .45,
                          ),

                          disabledForegroundColor:
                              Colors.white,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // STOP DRYING
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,

                      child:
                          ElevatedButton
                              .icon(
                        onPressed:
                            stopSending
                                ? null
                                : stopDrying,

                        icon:
                            stopSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .stop_circle,
                                  ),

                        label:
                            const Text(
                          "STOP DRYING",
                        ),

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.red,
                          foregroundColor:
                              Colors.white,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // TARE
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,

                      child:
                          OutlinedButton
                              .icon(
                        onPressed:
                            tareSending
                                ? null
                                : tareWeight,

                        icon:
                            tareSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .restart_alt,
                                  ),

                        label:
                            const Text(
                          "TARE / RESET WEIGHT",
                        ),

                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              Colors.orange,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    timer?.cancel();

    temperatureController.dispose();
    humidityController.dispose();

    super.dispose();
  }
}