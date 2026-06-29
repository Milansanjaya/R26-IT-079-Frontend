import 'package:flutter/material.dart';

import '../widgets/traceability_stat_card.dart';
import '../widgets/processing_record_card.dart';
import '../widgets/quick_action_card.dart';

import '../services/traceability_service.dart';
import '../models/traceability_dashboard_model.dart';
import 'processing_reports_screen.dart';

class WasteTraceabilityScreen extends StatefulWidget {
  const WasteTraceabilityScreen({super.key});

  @override
  State<WasteTraceabilityScreen> createState() =>
      _WasteTraceabilityScreenState();
}

class _WasteTraceabilityScreenState extends State<WasteTraceabilityScreen> {
  TraceabilityDashboardModel? dashboard;

  bool loading = true;
  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final result = await TraceabilityService.getDashboard();

      setState(() {
        dashboard = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final d = dashboard!;

    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffEAF7FF),
        centerTitle: true,
        title: const Text(
          "Waste & Traceability Dashboard",
          style: TextStyle(
            color: Color(0xff214E77),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff214E77)),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),

            Row(
              children: [
                TraceabilityStatCard(
                  icon: Icons.inventory,
                  iconColor: Colors.green,
                  title: "Total Batches",
                  value: d.totalBatches.toString(),
                  subtitle: "This Month",
                ),

                TraceabilityStatCard(
                  icon: Icons.scale,
                  iconColor: Colors.brown,
                  title: "Total Waste\n(kg)",
                  value: d.totalWasteKg.toStringAsFixed(1),
                  subtitle: "This Month",
                ),

                TraceabilityStatCard(
                  icon: Icons.show_chart,
                  iconColor: Colors.pink,
                  title: "Inprogress\n",
                  value: d.inProgressBatches.toString(),
                  subtitle: "This Month",
                ),

                TraceabilityStatCard(
                  icon: Icons.assignment,
                  iconColor: Colors.blue,
                  title: "completed\nBatches",
                  value: d.completedBatches.toString(),
                  subtitle: "Total",
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  [
                      Text(
                        "Recent Processing Records",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff214E77),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProcessingReportsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const ProcessingRecordCard(
                    batchId: "BATCH-2025-056",
                    fishType: "Sprats",
                    date: "25 May 2025",
                    time: "10:30 AM",
                    wasteKg: 113.5,
                    wastePercentage: 35,
                  ),

                  Divider(),

                  const ProcessingRecordCard(
                    batchId: "BATCH-2025-055",
                    fishType: "Mackerel",
                    date: "24 May 2025",
                    time: "03:15 PM",
                    wasteKg: 86.2,
                    wastePercentage: 16,
                  ),

                  Divider(),

                  const ProcessingRecordCard(
                    batchId: "BATCH-2025-054",
                    fishType: "Tuna",
                    date: "23 May 2025",
                    time: "09:45 AM",
                    wasteKg: 72.8,
                    wastePercentage: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff214E77),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      QuickActionCard(
                        icon: Icons.add_circle_outline,
                        title: "Add New Batch",
                        onTap: () {},
                      ),

                      QuickActionCard(
                        icon: Icons.bar_chart,
                        title: "View Reports",
                        onTap: () {},
                      ),

                      QuickActionCard(
                        icon: Icons.download,
                        title: "Export Data",
                        onTap: () {},
                      ),

                      QuickActionCard(
                        icon: Icons.settings,
                        title: "Settings",
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Center(
              child: Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
