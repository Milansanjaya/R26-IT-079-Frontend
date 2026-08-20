import 'package:flutter/material.dart';
import '../../models/processing_report_model.dart';
import '../../models/traceability_dashboard_model.dart';
import '../../services/Batch/processing_report_service.dart';
import '../../services/Batch/traceability_service.dart';
import '../../widgets/Batch/colors.dart';
import 'batch_details_screen.dart';
import 'edit_batch_screen.dart';
import '../admin/admin_home_screen.dart';

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
  String selectedDateFilter = "All Dates";
  bool loading = true;

  final List<ProcessingReportModel> sampleReports = [
    ProcessingReportModel(
      batchId: "BATCH-2025-055",
      fishType: "Mackerel",
      date: "24 May 2025 • 03:15 PM",
      rawWeight: 595.0,
      predictedWaste: 95.2,
      wastePercentage: 16.0,
      status: "Completed",
    ),
    ProcessingReportModel(
      batchId: "BATCH-2025-054",
      fishType: "Tuna",
      date: "23 May 2025 • 09:45 AM",
      rawWeight: 520.0,
      predictedWaste: 72.8,
      wastePercentage: 14.0,
      status: "Completed",
    ),
    ProcessingReportModel(
      batchId: "BATCH-2025-053",
      fishType: "Sprats",
      date: "22 May 2025 • 02:20 PM",
      rawWeight: 545.0,
      predictedWaste: 65.4,
      wastePercentage: 12.0,
      status: "Completed",
    ),
    ProcessingReportModel(
      batchId: "BATCH-2025-052",
      fishType: "Sardine",
      date: "21 May 2025 • 10:10 AM",
      rawWeight: 575.0,
      predictedWaste: 92.1,
      wastePercentage: 16.0,
      status: "In Progress",
    ),
    ProcessingReportModel(
      batchId: "BATCH-2025-051",
      fishType: "Anchovy",
      date: "20 May 2025 • 04:30 PM",
      rawWeight: 530.0,
      predictedWaste: 58.3,
      wastePercentage: 11.0,
      status: "Completed",
    ),
    ProcessingReportModel(
      batchId: "BATCH-2025-050",
      fishType: "Mackerel",
      date: "19 May 2025 • 11:05 AM",
      rawWeight: 505.0,
      predictedWaste: 65.7,
      wastePercentage: 13.0,
      status: "Completed",
    ),
  ];

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
        reports = reportData.isNotEmpty ? reportData : List.from(sampleReports);
        filteredReports = List.from(reports);
        loading = false;
      });
    } catch (_) {
      setState(() {
        reports = List.from(sampleReports);
        filteredReports = List.from(sampleReports);
        loading = false;
      });
    }
  }

  void filterReports() {
    setState(() {
      filteredReports = reports.where((report) {
        final search = searchController.text.toLowerCase().trim();

        final matchesSearch = search.isEmpty ||
            report.batchId.toLowerCase().contains(search) ||
            report.fishType.toLowerCase().contains(search);

        final matchesFish =
            selectedFish == "All Fish Types" || report.fishType == selectedFish;

        final matchesStatus = selectedStatus == "All Status" ||
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
      try {
        await ProcessingReportService.deleteBatch(batchId);
      } catch (_) {}

      setState(() {
        reports.removeWhere((r) => r.batchId == batchId);
        filterReports();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Batch $batchId deleted successfully"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          Image.asset('assets/images/logo.png', height: 55),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Screen Header Title
              const Center(
                child: Text(
                  "Batch Records\nOverview",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff103F73),
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4 Metrics Bar Cards in Horizontal Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildMetricCard(
                      icon: Icons.assignment_outlined,
                      iconColor: Colors.blue,
                      title: "Total Batches",
                      value: "${dashboard?.totalBatches ?? reports.length}",
                      subtitle: "This Month",
                    ),
                    _buildMetricCard(
                      icon: Icons.autorenew_rounded,
                      iconColor: Colors.green,
                      title: "Total Waste (kg)",
                      value: (dashboard?.totalWasteKg ?? 1245.6).toStringAsFixed(1),
                      subtitle: "This Month",
                    ),
                    _buildMetricCard(
                      icon: Icons.pie_chart_outline_rounded,
                      iconColor: Colors.orange,
                      title: "Avg. Waste (%)",
                      value: "${(dashboard?.avgWastePercentage ?? 18.4).toStringAsFixed(1)}%",
                      subtitle: "This Month",
                    ),
                    _buildMetricCard(
                      icon: Icons.assignment_turned_in_outlined,
                      iconColor: Colors.purple,
                      title: "Records",
                      value: "${reports.length * 40}",
                      subtitle: "Total",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search & Filters Header
              Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Search & Filters",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Input Row with Filter Button
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => filterReports(),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Search by Batch ID or Fish Type...",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFC),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_alt_outlined, color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Filter",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 3 Dropdowns Row: All Dates, All Fish Types, All Status
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedDateFilter,
                      decoration: _dropdownDecoration("Date", Icons.calendar_today_outlined),
                      items: const [
                        DropdownMenuItem(value: "All Dates", child: Text("All Dates", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "This Month", child: Text("This Month", style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) => setState(() => selectedDateFilter = val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedFish,
                      decoration: _dropdownDecoration("Fish", Icons.set_meal_outlined),
                      items: const [
                        DropdownMenuItem(value: "All Fish Types", child: Text("All Fish Types", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "Mackerel", child: Text("Mackerel", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "Tuna", child: Text("Tuna", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "Sprats", child: Text("Sprats", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "Sardine", child: Text("Sardine", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "Anchovy", child: Text("Anchovy", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "Salaya", child: Text("Salaya", style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        selectedFish = val!;
                        filterReports();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedStatus,
                      decoration: _dropdownDecoration("Status", Icons.access_time),
                      items: const [
                        DropdownMenuItem(value: "All Status", child: Text("All Status", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "Completed", child: Text("Completed", style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: "In Progress", child: Text("In Progress", style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        selectedStatus = val!;
                        filterReports();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Batch Records Table Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Batch Records",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Total ${filteredReports.length} records",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Table Headers Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text("Batch ID", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Expanded(flex: 3, child: Text("Date & Time", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Expanded(flex: 2, child: Text("Fish Type", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Expanded(flex: 3, child: Text("Waste (kg) & %", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Expanded(flex: 2, child: Text("Status", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    SizedBox(width: 60, child: Text("Action", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Batch Records Table Rows List
              if (filteredReports.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: const Center(
                    child: Text(
                      "No batch records found",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredReports.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200, height: 16),
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    final isCompleted = report.status.toLowerCase() == "completed";

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          // Batch ID
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDF5FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.set_meal_outlined, size: 14, color: Colors.blue),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    report.batchId,
                                    style: const TextStyle(
                                      color: Color(0xff103F73),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Date & Time
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.date.split("•")[0].trim(),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                Text(
                                  report.date.contains("•") ? report.date.split("•")[1].trim() : "",
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),

                          // Fish Type
                          Expanded(
                            flex: 2,
                            child: Text(
                              report.fishType,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Waste (kg) & %
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${report.predictedWaste.toStringAsFixed(1)} kg (${report.wastePercentage.toStringAsFixed(0)}%)",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ),

                          // Status Tag
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isCompleted ? Colors.green : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    report.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted ? Colors.green.shade800 : Colors.orange.shade800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Actions (View, Edit, Delete)
                          SizedBox(
                            width: 75,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // View (Eye icon)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BatchDetailsScreen(batch: report),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Edit (Pencil icon)
                                GestureDetector(
                                  onTap: () async {
                                    final updatedReport = await Navigator.push<ProcessingReportModel>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditBatchScreen(batch: report),
                                      ),
                                    );

                                    if (updatedReport != null) {
                                      setState(() {
                                        final index = reports.indexWhere((r) => r.batchId == updatedReport.batchId);
                                        if (index != -1) {
                                          reports[index] = updatedReport;
                                        }
                                        filterReports();
                                      });
                                    }
                                  },
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Delete (Trash icon)
                                GestureDetector(
                                  onTap: () => deleteBatch(report.batchId),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: 125,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
