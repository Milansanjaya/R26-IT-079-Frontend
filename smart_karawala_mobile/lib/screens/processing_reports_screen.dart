import 'package:flutter/material.dart';

import '../models/processing_report_model.dart';
import '../services/processing_report_service.dart';

import '../widgets/report_filter_section.dart';
import '../widgets/processing_record_card.dart';

class ProcessingReportsScreen extends StatefulWidget {
  const ProcessingReportsScreen({super.key});

  @override
  State<ProcessingReportsScreen> createState() =>
      _ProcessingReportsScreenState();
}

class _ProcessingReportsScreenState
    extends State<ProcessingReportsScreen> {

  List<ProcessingReportModel> reports = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final data =
          await ProcessingReportService.getReports();

      setState(() {
        reports = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xffEAF7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xff214E77),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const SizedBox(height: 10),

            const Text(
              "Processing Reports",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xff214E77),
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  children: [

                    const ReportFilterSection(),

                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView.separated(
                        itemCount: reports.length,

                        separatorBuilder: (_, __) =>
                            const Divider(),

                        itemBuilder: (context, index) {

                          final report = reports[index];

                          return ProcessingRecordCard(
                            batchId: report.batchId,
                            fishType: report.fishType,
                            date: report.date,
                            time: "",
                            wasteKg: report.predictedWaste,
                            wastePercentage:
                                report.wastePercentage,
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
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}