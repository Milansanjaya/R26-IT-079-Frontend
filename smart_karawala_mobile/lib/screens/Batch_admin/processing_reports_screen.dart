import 'package:flutter/material.dart';
import '../../models/processing_report_model.dart';
import '../admin/admin_home_screen.dart';
import '../../services/Batch/processing_report_service.dart';
import '../../widgets/Batch/colors.dart';
import '../../widgets/Traceability/report_filter_section.dart';
import '../../widgets/Traceability/processing_record_card.dart';
import 'batch_details_screen.dart';

class ProcessingReportsScreen extends StatefulWidget {
  const ProcessingReportsScreen({super.key});

  @override
  State<ProcessingReportsScreen> createState() =>
      _ProcessingReportsScreenState();
}

class _ProcessingReportsScreenState extends State<ProcessingReportsScreen> {
  List<ProcessingReportModel> reports = [];
  List<ProcessingReportModel> filteredReports = [];

  String searchText = "";
  String selectedFish = "All Fish Types";
  String selectedStatus = "All Status";
  String selectedDate = "All Dates";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final data = await ProcessingReportService.getReports();

      setState(() {
        reports = data;
        filteredReports = data;
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
        final matchesSearch =
            searchText.isEmpty ||
            report.batchId.toLowerCase().contains(searchText.toLowerCase()) ||
            report.fishType.toLowerCase().contains(searchText.toLowerCase());

        final matchesFish =
            selectedFish == "All Fish Types" || report.fishType == selectedFish;

        final matchesStatus =
            selectedStatus == "All Status" ||
            report.status.toLowerCase() == selectedStatus.toLowerCase();

        return matchesSearch && matchesFish && matchesStatus;
      }).toList();
    });
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Processing Reports",
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
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminHomeScreen(),
                ),
              );
            },
            child: Image.asset('assets/images/logo.png', height: 55),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: Container(
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
                  children: [
                    ReportFilterSection(
                      onSearch: (value) {
                        searchText = value;
                        filterReports();
                      },
                      onFishChanged: (value) {
                        selectedFish = value!;
                        filterReports();
                      },
                      onStatusChanged: (value) {
                        selectedStatus = value!;
                        filterReports();
                      },
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: filteredReports.isEmpty
                          ? const Center(
                              child: Text(
                                "No reports found",
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredReports.length,
                              separatorBuilder: (_, __) => Divider(color: Colors.grey.shade100, height: 24),
                              itemBuilder: (context, index) {
                                final report = filteredReports[index];

                                return ProcessingRecordCard(
                                  batchId: report.batchId,
                                  fishType: report.fishType,
                                  date: report.date,
                                  time: "",
                                  status: report.status,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            BatchDetailsScreen(batch: report),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Powered by Smart Karawala",
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
