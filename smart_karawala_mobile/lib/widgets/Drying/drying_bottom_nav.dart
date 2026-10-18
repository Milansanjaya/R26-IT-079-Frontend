import 'package:flutter/material.dart';

import '../../screens/drying/drying_dashboard_screen.dart';
import '../../screens/drying/drying_control_screen.dart';
/*import '../../screens/drying/live_graph_screen.dart';
import '../../screens/drying/device_status_screen.dart';*/

class DryingBottomNav extends StatelessWidget {
  final int currentIndex;

  const DryingBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,

      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        Widget page;

        switch (index) {
          case 0:
            page = const DryingDashboardScreen();
            break;

          case 1:
            page = const DryingControlScreen();
            break;

          /*case 2:
            page = const LiveGraphScreen();
            break;

          case 3:
            page = const DeviceStatusScreen();
            break;*/

          default:
            page = const DryingDashboardScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },

      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.tune),
          label: "Control",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: "Graph",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.memory),
          label: "Status",
        ),
      ],
    );
  }
}