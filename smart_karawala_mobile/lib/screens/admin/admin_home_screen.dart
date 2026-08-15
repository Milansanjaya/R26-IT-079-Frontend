import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import '../../widgets/Batch/dashboard_card.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../Add_Batch/add_new_batch_screen.dart';
import '../Waste/waste_prediction_screen.dart';
import '../Salt/salt_prediction_screen.dart';
import '../Salt/salting_monitoring_screen.dart';
import '../Drying/drying_hub_screen.dart';
import '../../services/Salt/salt_service.dart';
import '../Waste/waste_traceability_screen.dart';
import '../admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  Widget _buildHomeBody(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Header navigation row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.menu, size: 22, color: AppColors.primary),
                  ),
                  Image.asset('assets/images/logo.png', height: 70),
                ],
              ),

              const SizedBox(height: 24),

              // Greeting & Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Back,",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Sanjaya",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search Bar & Filter layout
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search dry fish...",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 22),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Title for Admin Actions
              const Text(
                "Dashboard Panels",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              // Grid Actions
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddNewBatchScreen(),
                          ),
                        );
                      },
                      child: const DashboardCard(
                        icon: Icons.add_circle_outline_rounded,
                        title: "Add Batch",
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WastePredictionScreen(),
                          ),
                        );
                      },
                      child: const DashboardCard(
                        icon: Icons.auto_delete_outlined,
                        title: "Waste Prediction",
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SaltPredictionScreen(),
                          ),
                        );
                      },
                      child: const DashboardCard(
                        icon: Icons.opacity_rounded,
                        title: "Salt Prediction",
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WasteTraceabilityScreen(),
                          ),
                        );
                      },
                      child: const DashboardCard(
                        icon: Icons.assignment_outlined,
                        title: "Traceability",
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final batch = await SaltService.getLatestBatch();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SaltingMonitoringScreen(batchId: batch.batchId),
                          ),
                        );
                      },
                      child: const DashboardCard(
                        icon: Icons.water_drop_outlined,
                        title: "Salt Monitoring",
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DryingHubScreen(),
                          ),
                        );
                      },
                      child: const DashboardCard(
                        icon: Icons.wb_sunny_outlined,
                        title: "Drying",
                      ),
                    ),
                    const DashboardCard(
                      icon: Icons.tune_rounded,
                      title: "Drying Control",
                    ),
                    const DashboardCard(
                      icon: Icons.memory_outlined,
                      title: "IoT Status",
                    ),
                    const DashboardCard(
                      icon: Icons.notifications_none_rounded,
                      title: "Alerts",
                    ),
                    const DashboardCard(
                      icon: Icons.videocam_outlined,
                      title: "Live Camera",
                    ),
                    const DashboardCard(
                      icon: Icons.search_outlined,
                      title: "Defects",
                    ),
                    const DashboardCard(
                      icon: Icons.history_rounded,
                      title: "Inspection",
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminDashboardScreen(),
                          ),
                        );
                      },
                      child: const DashboardCard(
                        icon: Icons.admin_panel_settings_outlined,
                        title: "Admin Panel",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentIndex == 0 ? _buildHomeBody(context) : const AdminProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[800],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
