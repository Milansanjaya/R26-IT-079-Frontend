import 'package:flutter/material.dart';
import 'admin_home_screen.dart';

import '../../widgets/Batch/colors.dart';
import '../Add_Batch/add_new_batch_screen.dart';
import '../Add_company/add_company_screen.dart';
import '../Batch_admin/batch_records_dashboard_screen.dart';
import '../Salt/salt_prediction_screen.dart';
import '../Salt/salting_monitoring_screen.dart';
import '../Waste/waste_notification_screen.dart';
import '../Waste/waste_prediction_screen.dart';
import '../Waste/waste_traceability_screen.dart';
import '../../services/Salt/salt_service.dart';
import '../../services/Batch/batch_service.dart';

class SystemOverviewDashboardScreen extends StatefulWidget {
  const SystemOverviewDashboardScreen({super.key});

  @override
  State<SystemOverviewDashboardScreen> createState() =>
      _SystemOverviewDashboardScreenState();
}

class _SystemOverviewDashboardScreenState
    extends State<SystemOverviewDashboardScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'AI & ML',
    'Operations',
    'Recycling',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHomeScreen(),
                        ),
                      );
                    },
                    child: Image.asset('assets/images/logo.png', height: 60),
                  ),
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Screen Title & Subtitle Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff1E3C72), Color(0xff2A5298)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff1E3C72).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.amber,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "System Architecture",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Smart Karawala Components",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "7 Intelligent Modules powering fish processing, ML prediction, salting monitoring & waste recycling.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // KPI Stats Overview Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildStatCard(
                      label: "Total Batches",
                      value: "7 Components",
                      icon: Icons.layers_rounded,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      label: "ML Models",
                      value: "Linear Reg.",
                      icon: Icons.psychology_rounded,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      label: "Salting Status",
                      value: "Auto-Track",
                      icon: Icons.timer_rounded,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      label: "Waste Network",
                      value: "Recycling Sync",
                      icon: Icons.recycling_rounded,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category Selector Filter Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "System Modules",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    "7 Core Units",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Render Component Cards based on Filter
              if (_shouldShow('Operations')) ...[
                // Component 1: Batch Management
                _buildComponentCard(
                  context,
                  badgeNumber: "COMPONENT 01",
                  categoryTag: "OPERATIONS",
                  title: "1. Batch Management",
                  subtitle:
                      "Create new fish processing batches. Store fish type, raw weight, date, and location while maintaining complete batch history and traceability.",
                  icon: Icons.inventory_2_rounded,
                  iconGradient: [const Color(0xff2193b0), const Color(0xff6dd5ed)],
                  featurePills: [
                    "Fish Type & Raw Weight",
                    "Date & Location",
                    "Batch History",
                    "Traceability",
                  ],
                  primaryActionLabel: "Create Batch",
                  primaryActionIcon: Icons.add_circle_outline_rounded,
                  onPrimaryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddNewBatchScreen(),
                      ),
                    );
                  },
                  secondaryActionLabel: "Batch History",
                  onSecondaryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BatchRecordsDashboardScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              if (_shouldShow('AI & ML')) ...[
                // Component 2: Waste Prediction (ML)
                _buildComponentCard(
                  context,
                  badgeNumber: "COMPONENT 02",
                  categoryTag: "MACHINE LEARNING",
                  title: "2. Waste Prediction (ML)",
                  subtitle:
                      "Predict fish waste using a Linear Regression model. Automatically calculate expected cleaned weight and save prediction results into the database.",
                  icon: Icons.auto_graph_rounded,
                  iconGradient: [const Color(0xffFF8008), const Color(0xffFFC837)],
                  featurePills: [
                    "Linear Regression",
                    "Cleaned Weight Calc",
                    "Database Storage",
                  ],
                  primaryActionLabel: "Predict Waste",
                  primaryActionIcon: Icons.analytics_outlined,
                  onPrimaryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WastePredictionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Component 3: Salt Prediction (ML)
                _buildComponentCard(
                  context,
                  badgeNumber: "COMPONENT 03",
                  categoryTag: "MACHINE LEARNING",
                  title: "3. Salt Prediction (ML)",
                  subtitle:
                      "Predict required salt amount based on cleaned weight. Recommend optimal salting duration and persist prediction results for each batch.",
                  icon: Icons.opacity_rounded,
                  iconGradient: [const Color(0xff4568DC), const Color(0xffB06AB3)],
                  featurePills: [
                    "Salt Amount Model",
                    "Optimal Duration",
                    "Per-Batch Saving",
                  ],
                  primaryActionLabel: "Predict Salt",
                  primaryActionIcon: Icons.water_drop_outlined,
                  onPrimaryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SaltPredictionScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              if (_shouldShow('Operations')) ...[
                // Component 4: Salting Monitoring
                _buildComponentCard(
                  context,
                  badgeNumber: "COMPONENT 04",
                  categoryTag: "REAL-TIME MONITORING",
                  title: "4. Salting Monitoring",
                  subtitle:
                      "Record salting start time, track elapsed salting duration, and automatically update salting status (Not Started → In Progress → Completed).",
                  icon: Icons.timer_rounded,
                  iconGradient: [const Color(0xff8E2DE2), const Color(0xff4A00E0)],
                  featurePills: [
                    "Start Time Record",
                    "Elapsed Timer",
                    "Auto Status Shift",
                  ],
                  primaryActionLabel: "Open Salting Monitor",
                  primaryActionIcon: Icons.play_circle_fill_rounded,
                  onPrimaryTap: () async {
                    try {
                      final batch = await SaltService.getLatestBatch();
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SaltingMonitoringScreen(batchId: batch.batchId),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],

              if (_shouldShow('Recycling')) ...[
                // Component 5: Waste Notification
                _buildComponentCard(
                  context,
                  badgeNumber: "COMPONENT 05",
                  categoryTag: "RECYCLING LOGISTICS",
                  title: "5. Waste Notification",
                  subtitle:
                      "Generate waste collection notifications to inform recycling or fish meal processing companies, and maintain full notification history.",
                  icon: Icons.notifications_active_rounded,
                  iconGradient: [const Color(0xff11998e), const Color(0xff38ef7d)],
                  featurePills: [
                    "Collection Alerts",
                    "Recycler Dispatch",
                    "Notification Logs",
                  ],
                  primaryActionLabel: "Send Notification",
                  primaryActionIcon: Icons.send_rounded,
                  onPrimaryTap: () async {
                    double wasteVal = 0.0;
                    try {
                      final latestBatch = await BatchService.getLatestBatch();
                      wasteVal = latestBatch.predictedWaste;
                    } catch (_) {}
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WasteNotificationScreen(
                          predictedWaste: wasteVal,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Component 6: Company Management
                _buildComponentCard(
                  context,
                  badgeNumber: "COMPONENT 06",
                  categoryTag: "RECYCLING DIRECTORY",
                  title: "6. Company Management",
                  subtitle:
                      "Add, update, view, and delete recycling companies. Store full company details and logistics contacts for waste notification dispatch.",
                  icon: Icons.business_center_rounded,
                  iconGradient: [const Color(0xff00B4DB), const Color(0xff0083B0)],
                  featurePills: [
                    "CRUD Companies",
                    "Contact Details",
                    "Waste Partners",
                  ],
                  primaryActionLabel: "Manage Companies",
                  primaryActionIcon: Icons.add_business_rounded,
                  onPrimaryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCompanyScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              if (_shouldShow('Operations')) ...[
                // Component 7: Dashboard & Batch History
                _buildComponentCard(
                  context,
                  badgeNumber: "COMPONENT 07",
                  categoryTag: "ANALYTICS & HISTORY",
                  title: "7. Dashboard & History",
                  subtitle:
                      "Display total batches, waste predictions, and notifications. View complete batch records, processing history, and support end-to-end traceability.",
                  icon: Icons.bar_chart_rounded,
                  iconGradient: [const Color(0xff0F2027), const Color(0xff2C5364)],
                  featurePills: [
                    "Total Batch Metrics",
                    "Waste History",
                    "End-to-End Traceability",
                  ],
                  primaryActionLabel: "View Batch Records",
                  primaryActionIcon: Icons.table_chart_rounded,
                  onPrimaryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BatchRecordsDashboardScreen(),
                      ),
                    );
                  },
                  secondaryActionLabel: "Traceability",
                  onSecondaryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WasteTraceabilityScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              const Divider(),
              const SizedBox(height: 16),

              const Center(
                child: Text(
                  "Smart Karawala • Intelligent Fish Processing System",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShow(String category) {
    if (_selectedCategory == 'All') return true;
    return _selectedCategory == category;
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCard(
    BuildContext context, {
    required String badgeNumber,
    required String categoryTag,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconGradient,
    required List<String> featurePills,
    required String primaryActionLabel,
    required IconData primaryActionIcon,
    required VoidCallback onPrimaryTap,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: iconGradient.first.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeNumber,
                  style: TextStyle(
                    color: iconGradient.first,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  categoryTag,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Header Row with Gradient Icon & Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: iconGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: iconGradient.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Feature Pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: featurePills.map((pill) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffF6F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xffE2ECF8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: iconGradient.first,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pill,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff214E77),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onPrimaryTap,
                    icon: Icon(primaryActionIcon, size: 18, color: Colors.white),
                    label: Text(
                      primaryActionLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              if (secondaryActionLabel != null && onSecondaryTap != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onSecondaryTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        secondaryActionLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
