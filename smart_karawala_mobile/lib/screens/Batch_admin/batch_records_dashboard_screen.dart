import 'package:flutter/material.dart';
import '../../models/processing_report_model.dart';
import '../../models/traceability_dashboard_model.dart';
import '../../services/Batch/processing_report_service.dart';
import '../../services/Batch/traceability_service.dart';
import '../../widgets/Batch/colors.dart';
import 'batch_details_screen.dart';
import 'edit_batch_screen.dart';

class BatchRecordsDashboardScreen extends StatefulWidget {
  const BatchRecordsDashboardScreen({super.key});

  @override
  State<BatchRecordsDashboardScreen> createState() =>
      _BatchRecordsDashboardScreenState();
}

class _BatchRecordsDashboardScreenState
    extends State<BatchRecordsDashboardScreen> {
  TraceabilityDashboardModel? dashboard;
  List<ProcessingReportModel> reports = [];
  List<ProcessingReportModel> filteredReports = [];
  final TextEditingController searchController = TextEditingController();

  String selectedFish = "All Fish Types";
  String selectedStatus = "All Status";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final dashboardData = await TraceabilityService.getDashboard();
      final reportData = await ProcessingReportService.getReports();

      setState(() {
        dashboard = dashboardData;
        reports = reportData;
        filteredReports = reportData;
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

  void filterReports() {
    setState(() {
      filteredReports = reports.where((report) {
        final search = searchController.text.toLowerCase();

        final matchesSearch =
            search.isEmpty ||
            report.batchId.toLowerCase().contains(search) ||
            report.fishType.toLowerCase().contains(search);

        final matchesFish =
            selectedFish == "All Fish Types" || report.fishType == selectedFish;

        final matchesStatus =
            selectedStatus == "All Status" ||
            report.status.toLowerCase() == selectedStatus.toLowerCase();

        return matchesSearch && matchesFish && matchesStatus;
      }).toList();
    });
  }

  Future<void> deleteBatch(String batchId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Batch",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: Text("Are you sure you want to delete batch\n$batchId?"),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ProcessingReportService.deleteBatch(batchId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Batch deleted successfully"), backgroundColor: Colors.green),
      );

      await loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
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
          "Batch Records",
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
      body: RefreshIndicator(
        onRefresh: loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Row 1
              Row(
                children: [
                  buildStatCard(
                    Icons.inventory_2_outlined,
                    Colors.blue,
                    "Total Batches",
                    d.totalBatches.toString(),
                    "This Month",
                  ),
                  buildStatCard(
                    Icons.scale_outlined,
                    Colors.green,
                    "Total Waste",
                    "${d.totalWasteKg.toStringAsFixed(1)} kg",
                    "This Month",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Statistics Row 2
              Row(
                children: [
                  buildStatCard(
                    Icons.hourglass_empty_outlined,
                    Colors.orange,
                    "In Progress",
                    d.inProgressBatches.toString(),
                    "This Month",
                  ),
                  buildStatCard(
                    Icons.check_circle_outline_rounded,
                    Colors.purple,
                    "Completed",
                    d.completedBatches.toString(),
                    "Total Batches",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search & Filters Card
              Container(
                width: double.infinity,
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
                      "Search & Filters",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      onChanged: (_) => filterReports(),
                      decoration: InputDecoration(
                        hintText: "Search by Batch ID or Fish Type",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 22),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedFish,
                            decoration: _inputDecoration("Fish Type", Icons.set_meal_outlined),
                            items: const [
                              DropdownMenuItem(value: "All Fish Types", child: Text("All Fish Types")),
                              DropdownMenuItem(value: "Salaya", child: Text("Salaya")),
                              DropdownMenuItem(value: "Thora", child: Text("Thora")),
                              DropdownMenuItem(value: "Hurulla", child: Text("Hurulla")),
                              DropdownMenuItem(value: "Sprats", child: Text("Sprats")),
                              DropdownMenuItem(value: "Mackerel", child: Text("Mackerel")),
                            ],
                            onChanged: (value) {
                              selectedFish = value!;
                              filterReports();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedStatus,
                            decoration: _inputDecoration("Status", Icons.verified_user_outlined),
                            items: const [
                              DropdownMenuItem(value: "All Status", child: Text("All Status")),
                              DropdownMenuItem(value: "Completed", child: Text("Completed")),
                              DropdownMenuItem(value: "In Progress", child: Text("In Progress")),
                              DropdownMenuItem(value: "Pending", child: Text("Pending")),
                            ],
                            onChanged: (value) {
                              selectedStatus = value!;
                              filterReports();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Records title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Batch Records",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    "${filteredReports.length} records",
                    style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Records Card List
              if (filteredReports.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
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
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      "No batch records found",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
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
                        border: Border.all(color: Colors.grey.shade100, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Batch ID & Status Tag
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  report.batchId,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: report.status == "Completed"
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  report.status,
                                  style: TextStyle(
                                    color: report.status == "Completed"
                                        ? Colors.green.shade800
                                        : Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Details: Date & Fish Type
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text(
                                report.date,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 20),
                              Icon(Icons.set_meal_outlined, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text(
                                report.fishType,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Color(0xFFF1F3F5)),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BatchDetailsScreen(batch: report),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.visibility_outlined, size: 16),
                                label: const Text("View"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditBatchScreen(batch: report),
                                    ),
                                  );

                                  if (result == true) {
                                    loadData();
                                  }
                                },
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text("Edit"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.orange.shade700,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => deleteBatch(report.batchId),
                                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                label: const Text("Delete"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
      ),
    );
  }

  Widget buildStatCard(
    IconData icon,
    Color color,
    String title,
    String value,
    String subtitle,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 18),
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
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
