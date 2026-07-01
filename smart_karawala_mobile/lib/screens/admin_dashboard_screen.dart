import 'package:flutter/material.dart';

import '../widgets/dashboard_menu_card.dart';

import 'waste_traceability_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Icon(Icons.menu),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        "Smart",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("කරවල"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                "Hi, Sanjaya",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff103F73),
                ),
              ),

              const SizedBox(height: 20),

              //------------------------------------------------
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
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.tune),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              DashboardMenuCard(
                icon: Icons.bar_chart,
                iconColor: Colors.blue,
                backgroundColor: const Color(0xffEDF5FF),
                title: "Sales Dashboard",
                subtitle:
                    "Track sales performance, revenue and top-selling products.",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sales Dashboard coming soon"),
                    ),
                  );
                },
              ),

              DashboardMenuCard(
                icon: Icons.assignment,
                iconColor: Colors.green,
                backgroundColor: const Color(0xffEFFAF1),
                title: "Batch Records Dashboard",
                subtitle: "View and manage all dry fish batches and records.",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Batch Records coming soon")),
                  );
                },
              ),

              DashboardMenuCard(
                icon: Icons.pie_chart,
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


              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
