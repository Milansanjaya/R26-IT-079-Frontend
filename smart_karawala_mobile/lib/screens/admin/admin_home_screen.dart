import 'package:flutter/material.dart';

import '../../widgets/Batch/dashboard_card.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

import '../Add_Batch/add_new_batch_screen.dart';

import '../Waste/waste_prediction_screen.dart';
import '../Waste/waste_traceability_screen.dart';

import '../Salt/salt_prediction_screen.dart';
import '../Salt/salting_monitoring_screen.dart';
import '../../services/Salt/salt_service.dart';

import '../admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'system_overview_dashboard_screen.dart';


              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

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

                  Container(
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,

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