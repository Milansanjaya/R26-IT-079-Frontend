import 'package:flutter/material.dart';
import '../drying/drying_system_screen.dart';
import '../../widgets/Batch/dashboard_card.dart';
import '../../widgets/admin_bottom_nav.dart';

import '../Add_Batch/add_new_batch_screen.dart';

import '../Waste/waste_prediction_screen.dart';
import '../Waste/waste_traceability_screen.dart';

import '../Salt/salt_prediction_screen.dart';
import '../Salt/salting_monitoring_screen.dart';
import '../../services/Salt/salt_service.dart';

import '../admin_dashboard_screen.dart';

/// DRYING MODULE
import '../drying/drying_dashboard_screen.dart';
import '../drying/drying_control_screen.dart';
import '../drying/live_graph_screen.dart';
import '../drying/device_status_screen.dart';
import '../drying/alerts_screen.dart';
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      bottomNavigationBar: const AdminBottomNav(),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            children: [

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  const Icon(
                    Icons.menu,
                    size: 28,
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: const [

                      Text(
                        "Smart",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Text("කරවල"),

                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hi , Sanjaya",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff214E77),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText:
                            "Search dry fish...",
                        prefixIcon:
                            const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,

                  children: [

  /// Add New Batch
 GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DryingSystemScreen(),
      ),
    );
  },
  child: const DashboardCard(
    icon: Icons.wb_sunny,
    title: "Drying System",
  ),
),

  /// Waste Prediction
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WastePredictionScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.bar_chart,
      title: "Waste Prediction",
    ),
  ),

  /// Salt Prediction
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SaltPredictionScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.grain,
      title: "Salt Prediction",
    ),
  ),

  /// Waste & Traceability
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const WasteTraceabilityScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.assignment,
      title: "Waste & Traceability",
    ),
  ),

  /// Salt Monitoring
  GestureDetector(
    onTap: () async {

      final batch =
          await SaltService.getLatestBatch();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SaltingMonitoringScreen(
            batchId: batch.batchId,
          ),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.water_drop,
      title: "Salt Monitoring",
    ),
  ),

  /// Drying Dashboard
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DryingDashboardScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.wb_sunny,
      title: "Drying Dashboard",
    ),
  ),

  /// Drying Control
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DryingControlScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.tune,
      title: "Drying Control",
    ),
  ),

  /// Live Graph
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LiveGraphScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.show_chart,
      title: "Live Graph",
    ),
  ),

  /// IoT Status
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DeviceStatusScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.memory,
      title: "IoT Status",
    ),
  ),

  /// Alerts
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AlertsScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.notifications,
      title: "Alerts",
    ),
  ),

  /// Live Camera
  GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Live Camera Coming Soon"),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.camera_alt,
      title: "Live Camera",
    ),
  ),

  /// Defects
  GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Defects Module Coming Soon"),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.search,
      title: "Defects",
    ),
  ),

  /// Inspection History
  GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inspection History Coming Soon"),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.history,
      title: "Inspection History",
    ),
  ),

  /// Admin Dashboard
  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AdminDashboardScreen(),
        ),
      );
    },
    child: const DashboardCard(
      icon: Icons.admin_panel_settings,
      title: "Admin Dashboard",
    ),
  ),

],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}