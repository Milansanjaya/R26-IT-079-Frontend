import 'package:flutter/material.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/admin_bottom_nav.dart';

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, size: 28),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        "Smart",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("කරවල"),
                    ],
                  )
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
                        hintText: "Search dry fish...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune),
                  )
                ],
              ),

              const SizedBox(height: 25),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: const [

                    DashboardCard(
                      icon: Icons.add_circle_outline,
                      title: "Add New Batch",
                    ),

                    DashboardCard(
                      icon: Icons.bar_chart,
                      title: "Waste Prediction",
                    ),

                    DashboardCard(
                      icon: Icons.grain,
                      title: "Salt Prediction",
                    ),

                    DashboardCard(
                      icon: Icons.assignment,
                      title: "Waste & Traceability",
                    ),

                    DashboardCard(
                      icon: Icons.water_drop,
                      title: "Salting Monitor",
                    ),

                    DashboardCard(
                      icon: Icons.wb_sunny,
                      title: "Drying Dashboard",
                    ),

                    DashboardCard(
                      icon: Icons.tune,
                      title: "Drying Control",
                    ),

                    DashboardCard(
                      icon: Icons.memory,
                      title: "IoT Status",
                    ),

                    DashboardCard(
                      icon: Icons.notifications,
                      title: "Alerts",
                    ),

                    DashboardCard(
                      icon: Icons.camera_alt,
                      title: "Live Camera",
                    ),

                    DashboardCard(
                      icon: Icons.search,
                      title: "Defects",
                    ),

                    DashboardCard(
                      icon: Icons.history,
                      title: "Inspection History",
                    ),

                    DashboardCard(
                      icon: Icons.admin_panel_settings,
                      title: "Admin Dashboard",
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