import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/salting_monitor_model.dart';
import '../../services/Salt/salting_monitor_service.dart';

import '../../widgets/Salt_monitoring/monitoring_header_card.dart';
import '../../widgets/Salt_monitoring/monitoring_progress_card.dart';
import '../../widgets/Salt_monitoring/monitoring_recommendation_card.dart';
import '../../widgets/Salt_monitoring/monitoring_status_card.dart';
import '../../widgets/Salt_monitoring/monitoring_time_card.dart';
import '../../widgets/Salt_monitoring/monitoring_update_button.dart';
import '../../widgets/Salt_monitoring/monitoring_weight_card.dart';

class SaltingMonitoringScreen extends StatefulWidget {
  final String batchId;

  const SaltingMonitoringScreen({
    super.key,
    required this.batchId,
  });

  @override
  State<SaltingMonitoringScreen> createState() =>
      _SaltingMonitoringScreenState();
}

class _SaltingMonitoringScreenState
    extends State<SaltingMonitoringScreen> {

  SaltingMonitorModel? monitor;

  bool loading = true;

  Timer? timer;

 @override
void initState() {
  super.initState();

  print("Batch ID = ${widget.batchId}");

  loadMonitoring();

  timer = Timer.periodic(
    const Duration(seconds: 5),
    (_) {
      loadMonitoring();
    },
  );
}

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadMonitoring() async {
    try {

      final result =
          await SaltingMonitorService.getMonitoring(
        widget.batchId,
      );

      if (!mounted) return;

      setState(() {
        monitor = result;
        loading = false;
      });

    } catch (e) {

      if (!mounted) return;

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

    final m = monitor!;

    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffEAF7FF),
        centerTitle: true,
        title: const Text(
          "Salting Monitoring",
          style: TextStyle(
            color: Color(0xff214E77),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xff214E77),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        //------------------------------------------------
            // Monitoring Header
            //------------------------------------------------
            MonitoringHeaderCard(
              batchId: m.batchId,
              fishType: m.fishType,
              startTime: m.startTime,
              status: m.status,
            ),

            const SizedBox(height: 16),

            //------------------------------------------------
            // Status Card
            //------------------------------------------------
            MonitoringStatusCard(
              status: m.status,
            ),

            const SizedBox(height: 20),

            //------------------------------------------------
            // Monitoring Cards
            //------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                MonitoringProgressCard(
                  progress: m.progress,
                ),

                const SizedBox(width: 10),

                MonitoringWeightCard(
                  weightLoss: m.weightLoss,
                  percentage: m.weightLossPercentage,
                ),

                const SizedBox(width: 10),

                MonitoringTimeCard(
                  remainingHours: m.remainingHours,
                ),
              ],
            ),

            const SizedBox(height: 20),
            
                        //------------------------------------------------
            // Recommendation Card
            //------------------------------------------------
            MonitoringRecommendationCard(
              status: m.status,
            ),

            const SizedBox(height: 20),

            //------------------------------------------------
            // Refresh Button
            //------------------------------------------------
            MonitoringUpdateButton(
              onPressed: loadMonitoring,
            ),

            const SizedBox(height: 25),
            const SizedBox(height: 25),
            const SizedBox(height: 25),

            //------------------------------------------------
            // Powered By
            //------------------------------------------------
            const Center(
              child: Text(
                "Powered by Smart Karawala",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}