import 'package:flutter/material.dart';

import '../models/processing_report_model.dart';
import '../models/traceability_dashboard_model.dart';

import '../services/processing_report_service.dart';
import '../services/traceability_service.dart';
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
  //---------------------------------------
  // Dashboard Data
  //---------------------------------------

  TraceabilityDashboardModel? dashboard;

  //---------------------------------------
  // Batch Records
  //---------------------------------------

  List<ProcessingReportModel> reports = [];
  List<ProcessingReportModel> filteredReports = [];

  //---------------------------------------
  // Search & Filters
  //---------------------------------------

  final TextEditingController searchController = TextEditingController();

  String selectedFish = "All Fish Types";
  String selectedStatus = "All Status";

  bool loading = true;

  //---------------------------------------
  // Init
  //---------------------------------------

  @override
  void initState() {
    super.initState();
    loadData();
  }

  //---------------------------------------
  // Load Dashboard + Reports
  //---------------------------------------

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

  //---------------------------------------
  // Search + Filter
  //---------------------------------------

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

  //---------------------------------------
  // Delete Batch
  //---------------------------------------

  Future<void> deleteBatch(String batchId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Batch"),
        content: Text("Are you sure you want to delete\n$batchId ?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ProcessingReportService.deleteBatch(batchId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Batch deleted successfully")),
      );

      await loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //---------------------------------------
  // Build
  //---------------------------------------

  @override
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

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        centerTitle: true,

        title: const Text(
          "Batch Records Overview",
          style: TextStyle(
            color: Color(0xff214E77),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadData,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              //--------------------------------------------------
              // Statistics Cards
              //--------------------------------------------------
              Row(
                children: [
                  buildStatCard(
                    Icons.inventory,
                    Colors.blue,
                    "Total Batches",
                    d.totalBatches.toString(),
                    "This Month",
                  ),

                  buildStatCard(
                    Icons.recycling,
                    Colors.green,
                    "Total Waste (kg)",
                    d.totalWasteKg.toStringAsFixed(1),
                    "This Month",
                  ),

                  buildStatCard(
                    Icons.trending_up,
                    Colors.orange,
                    "In Progress",
                    d.inProgressBatches.toString(),
                    "This Month",
                  ),

                  buildStatCard(
                    Icons.assignment,
                    Colors.purple,
                    "Completed",
                    d.completedBatches.toString(),
                    "Total",
                  ),
                ],
              ),

              const SizedBox(height: 30),

              //--------------------------------------------------
              // Search & Filters
              //--------------------------------------------------
              const Text(
                "Search & Filters",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff214E77),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,

                      onChanged: (_) => filterReports(),

                      decoration: InputDecoration(
                        hintText: "Search by Batch ID or Fish Type",

                        prefixIcon: const Icon(Icons.search),

                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  OutlinedButton.icon(
                    onPressed: () {},

                    icon: const Icon(Icons.filter_alt),

                    label: const Text("Filter"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedFish,

                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: "All Fish Types",
                          child: Text("All Fish Types"),
                        ),

                        DropdownMenuItem(
                          value: "Salaya",
                          child: Text("Salaya"),
                        ),

                        DropdownMenuItem(value: "Thora", child: Text("Thora")),

                        DropdownMenuItem(
                          value: "Hurulla",
                          child: Text("Hurulla"),
                        ),

                        DropdownMenuItem(
                          value: "Sprats",
                          child: Text("Sprats"),
                        ),

                        DropdownMenuItem(
                          value: "Mackerel",
                          child: Text("Mackerel"),
                        ),
                      ],

                      onChanged: (value) {
                        selectedFish = value!;

                        filterReports();
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,

                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: "All Status",
                          child: Text("All Status"),
                        ),

                        DropdownMenuItem(
                          value: "Completed",
                          child: Text("Completed"),
                        ),

                        DropdownMenuItem(
                          value: "In Progress",
                          child: Text("In Progress"),
                        ),

                        DropdownMenuItem(
                          value: "Pending",
                          child: Text("Pending"),
                        ),
                      ],

                      onChanged: (value) {
                        selectedStatus = value!;

                        filterReports();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // Records title
              //--------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Batch Records",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xff214E77),
                    ),
                  ),

                  Text(
                    "${filteredReports.length} records",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: Column(
                  children: [
                    //--------------------------------------------------
                    // Header
                    //--------------------------------------------------
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xffF5F8FC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),

                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Batch ID",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              "Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              "Fish",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              "Status",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          Expanded(
                            flex: 4,
                            child: Center(
                              child: Text(
                                "Action",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //--------------------------------------------------
                    // Records
                    //--------------------------------------------------
                    ListView.separated(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: filteredReports.length,

                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade300),

                      itemBuilder: (context, index) {
                        final report = filteredReports[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),

                          child: Row(
                            children: [
                              //------------------------------------------------
                              // Batch ID
                              //------------------------------------------------
                              Expanded(
                                flex: 3,
                                child: Text(
                                  report.batchId,
                                  style: const TextStyle(
                                    color: Color(0xff214E77),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              //------------------------------------------------
                              // Date
                              //------------------------------------------------
                              Expanded(flex: 2, child: Text(report.date)),

                              //------------------------------------------------
                              // Fish
                              //------------------------------------------------
                              Expanded(flex: 2, child: Text(report.fishType)),

                              //------------------------------------------------
                              // Status
                              //------------------------------------------------
                              Expanded(
                                flex: 2,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),

                                  decoration: BoxDecoration(
                                    color: report.status == "Completed"
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    report.status,
                                    style: TextStyle(
                                      color: report.status == "Completed"
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),

                              //------------------------------------------------
                              // Actions
                              //------------------------------------------------
                              Expanded(
                                flex: 4,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    IconButton(
                                      iconSize: 18,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.visibility,
                                        color: Color.fromARGB(
                                          255,
                                          77,
                                          135,
                                          241,
                                        ),
                                      ),

                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BatchDetailsScreen(
                                              batch: report,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),

                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditBatchScreen(batch: report),
                                          ),
                                        );

                                        if (result == true) {
                                          loadData();
                                        }
                                      },
                                    ),

                                    IconButton(
                                      iconSize: 18,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),

                                      onPressed: () {
                                        deleteBatch(report.batchId);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  "Powered by Smart Karawala",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Statistics Card
  //--------------------------------------------------

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
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),

        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(.12),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
