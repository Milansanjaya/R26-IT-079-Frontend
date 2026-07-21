import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/salting_monitor_model.dart';
import '../../services/Salt/salting_monitor_service.dart';
import '../../widgets/Batch/colors.dart';
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

class _SaltingMonitoringScreenState extends State<SaltingMonitoringScreen> {
  SaltingMonitorModel? monitor;
  bool loading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    debugPrint("Batch ID = ${widget.batchId}");
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
      final result = await SaltingMonitorService.getMonitoring(
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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final m = monitor!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Salting Monitoring",
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
          Image.asset('assets/images/logo.png', height: 28),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monitoring Header Card
            MonitoringHeaderCard(
              batchId: m.batchId,
              fishType: m.fishType,
              startTime: m.startTime,
              status: m.status,
            ),

            const SizedBox(height: 16),

            // Status Card
            MonitoringStatusCard(
              status: m.status,
            ),

            const SizedBox(height: 20),

            // Monitoring Details Row (Progress, Weight, Time)
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

            // Recommendation Card
            MonitoringRecommendationCard(
              status: m.status,
            ),

            const SizedBox(height: 24),

            // Refresh Button
            MonitoringUpdateButton(
              onPressed: loadMonitoring,
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Powered By Footer
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