import 'package:flutter/material.dart';

import 'drying_dashboard_screen.dart';
import 'drying_control_screen.dart';
import 'live_graph_screen.dart';
import 'device_status_screen.dart';
import 'alerts_screen.dart';
import '../admin/admin_home_screen.dart';

class DryingSystemScreen
    extends StatelessWidget {
  const DryingSystemScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffEAF7FF),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHomeScreen(),
                        ),
                      );
                    },
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Drying System",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xff234D73),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: .95,

                  children: [

                    _menuCard(
                      context,
                      icon:
                          Icons.dashboard,
                      title:
                          "Dashboard",
                      color: Colors.blue,
                      page:
                          const DryingDashboardScreen(),
                    ),

                    _menuCard(
                      context,
                      icon: Icons.tune,
                      title: "Control",
                      color: Colors.green,
                      page:
                          const DryingControlScreen(),
                    ),

                    _menuCard(
                      context,
                      icon:
                          Icons.show_chart,
                      title:
                          "Live Graph",
                      color:
                          Colors.orange,
                      page:
                          const LiveGraphScreen(),
                    ),

                    _menuCard(
                      context,
                      icon:
                          Icons.memory,
                      title:
                          "Device Status",
                      color:
                          Colors.deepPurple,
                      page:
                          const DeviceStatusScreen(),
                    ),

                    _menuCard(
                      context,
                      icon:
                          Icons.notifications,
                      title: "Alerts",
                      color: Colors.red,
                      page:
                          const AlertsScreen(),
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
    required Color color,
    required Widget page,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(18),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },

      child: Container(
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor:
                  color.withValues(alpha: 0.12),
              child: Icon(
                icon,
                color: color,
                size: 38,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}