import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/storage_service.dart';
import '../widgets/Batch/dashboard_menu_card.dart';

import 'auth/login_screen.dart';
import 'Waste/waste_traceability_screen.dart';
import 'admin/admin_home_screen.dart';
import 'admin/sales_dashboard_screen.dart';
import 'Batch_admin/batch_records_dashboard_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header navigation row with menu icon on left and logo on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminHomeScreen(),
                          ),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.menu,
                        size: 28,
                        color: Color(0xff103F73),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Greeting title matching screenshot
              const Text(
                "Hi ,Sanjaya",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff103F73),
                ),
              ),

              const SizedBox(height: 16),

              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF4F6F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search dry fish...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black87,
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Dashboard items
              DashboardMenuCard(
                icon: Icons.bar_chart_rounded,
                iconColor: Colors.blue,
                backgroundColor: const Color(0xffEDF5FF),
                title: "Sales Dashboard",
                subtitle:
                    "Track sales performance, revenue, and top-selling products.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SalesDashboardScreen(),
                    ),
                  );
                },
              ),

              DashboardMenuCard(
                icon: Icons.assignment_outlined,
                iconColor: Colors.green,
                backgroundColor: const Color(0xffEFFAF1),
                title: "Batch Records Dashboard",
                subtitle:
                    "View and manage all dry fish batches and their records.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BatchRecordsDashboardScreen(),
                    ),
                  );
                },
              ),

              DashboardMenuCard(
                icon: Icons.pie_chart_outline_rounded,
                iconColor: Colors.orange,
                backgroundColor: const Color(0xffFFF6EC),
                title: "Verification Dashboard",
                subtitle:
                    "Review verification status and ensure quality compliance.",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Verification Dashboard coming soon"),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
