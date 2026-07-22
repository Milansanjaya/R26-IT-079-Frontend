import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import '../../widgets/Traceability/traceability_stat_card.dart';
import '../../widgets/Traceability/processing_record_card.dart';
import '../../widgets/Traceability/quick_action_card.dart';

import '../../services/Batch/traceability_service.dart';
import '../../models/traceability_dashboard_model.dart';
import '../../models/processing_report_model.dart';
import '../Batch_admin/processing_reports_screen.dart';
import '../Batch_admin/batch_details_screen.dart';
import '../Add_Batch/add_new_batch_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final d = dashboard!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Waste & Traceability",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Image.asset('assets/images/logo.png', height: 40),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stat Cards (2x2 Grid)
            Row(
              children: [
                TraceabilityStatCard(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.green,
                  title: "Total Batches",
                  value: d.totalBatches.toString(),
                  subtitle: "This Month",
                ),
                TraceabilityStatCard(
                  icon: Icons.scale_outlined,
                  iconColor: Colors.deepOrange,
                  title: "Total Waste (kg)",
                  value: d.totalWasteKg.toStringAsFixed(1),
                  subtitle: "This Month",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TraceabilityStatCard(
                  icon: Icons.hourglass_empty_outlined,
                  iconColor: Colors.orange,
                  title: "In Progress",
                  value: d.inProgressBatches.toString(),
                  subtitle: "This Month",
                ),
                TraceabilityStatCard(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: Colors.blue,
                  title: "Completed Batches",
                  value: d.completedBatches.toString(),
                  subtitle: "Total Batches",
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Processing Records Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Records",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (d.recentBatches.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No recent records found",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    ...d.recentBatches.take(3).map((record) {
                      final isLast = d.recentBatches.indexOf(record) == d.recentBatches.length - 1 || d.recentBatches.indexOf(record) == 2;
                      return Column(
                        children: [
                          ProcessingRecordCard(
                            batchId: record.batchId,
                            fishType: record.fishType,
                            date: record.date,
                            time: "11:05 AM",
                            status: record.status,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BatchDetailsScreen(
                                    batch: ProcessingReportModel(
                                      batchId: record.batchId,
                                      fishType: record.fishType,
                                      rawWeight: record.rawWeight,
                                      status: record.status,
                                      date: record.date,
                                      predictedWaste: record.predictedWaste,
                                      wastePercentage: record.wastePercentage,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (!isLast) Divider(color: Colors.grey.shade100, height: 24),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      QuickActionCard(
                        icon: Icons.add_circle_outline_rounded,
                        title: "Add Batch",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddNewBatchScreen(),
                            ),
                          );
                        },
                      ),
                      QuickActionCard(
                        icon: Icons.bar_chart_rounded,
                        title: "View Reports",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProcessingReportsScreen(),
                            ),
                          );
                        },
                      ),
                      QuickActionCard(
                        icon: Icons.settings_outlined,
                        title: "Settings",
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            const Center(
              child: Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
