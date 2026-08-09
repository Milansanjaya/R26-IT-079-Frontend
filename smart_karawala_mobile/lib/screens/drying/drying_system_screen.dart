import 'package:flutter/material.dart';

import 'alerts_screen.dart';
import 'device_status_screen.dart';
import 'drying_control_screen.dart';
import 'drying_dashboard_screen.dart';
import 'live_graph_screen.dart';

class DryingSystemScreen extends StatelessWidget {
  const DryingSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// Header
              Row(
                children: [

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
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

              const SizedBox(height: 25),

              const Text(
                "Drying System",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff234D73),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Monitor and control the smart drying process",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.88,

                  children: [

                    _menuCard(
                      context,
                      icon: Icons.dashboard,
                      title: "Dashboard",
                      subtitle: "View live sensor values",
                      color: Colors.blue,
                      page: const DryingDashboardScreen(),
                    ),

                    _menuCard(
                      context,
                      icon: Icons.tune,
                      title: "Control",
                      subtitle: "Operate heater & fan",
                      color: Colors.green,
                      page: const DryingControlScreen(),
                    ),

                    _menuCard(
                      context,
                      icon: Icons.show_chart,
                      title: "Live Graph",
                      subtitle: "Temperature & humidity",
                      color: Colors.orange,
                      page: const LiveGraphScreen(),
                    ),

                    _menuCard(
                      context,
                      icon: Icons.memory,
                      title: "Device Status",
                      subtitle: "Arduino & sensors",
                      color: Colors.deepPurple,
                      page: const DeviceStatusScreen(),
                    ),

                    _menuCard(
                      context,
                      icon: Icons.notifications_active,
                      title: "Alerts",
                      subtitle: "Warnings & notifications",
                      color: Colors.red,
                      page: const AlertsScreen(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

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

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            CircleAvatar(
              radius: 34,
              backgroundColor: color.withOpacity(0.12),

              child: Icon(
                icon,
                size: 36,
                color: color,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}