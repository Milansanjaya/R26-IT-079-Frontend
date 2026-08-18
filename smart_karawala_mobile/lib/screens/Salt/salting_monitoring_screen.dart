import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/salting_monitor_model.dart';
import '../../services/Salt/salting_monitor_service.dart';
import '../../services/Salt/salting_service.dart';
import '../../widgets/Batch/colors.dart';
import '../../widgets/Salt_monitoring/monitoring_header_card.dart';
import '../../widgets/Salt_monitoring/monitoring_progress_card.dart';
import '../../widgets/Salt_monitoring/monitoring_recommendation_card.dart';
import '../../widgets/Salt_monitoring/monitoring_status_card.dart';
import '../../widgets/Salt_monitoring/monitoring_time_card.dart';
import '../../widgets/Salt_monitoring/monitoring_update_button.dart';
import '../../widgets/Salt_monitoring/monitoring_weight_card.dart';
import '../drying/time_prediction_screen.dart';

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
  bool isRefreshing = false;
  bool isCompleting = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    debugPrint("Batch ID = ${widget.batchId}");
    loadMonitoring();

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        loadMonitoring(isPeriodic: true);
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadMonitoring({bool isPeriodic = false, bool isUserManual = false}) async {
    if (isUserManual) {
      setState(() {
        isRefreshing = true;
      });
    }

    try {
      final result = await SaltingMonitorService.getMonitoring(
        widget.batchId,
      );

      if (!mounted) return;

      setState(() {
        monitor = result;
        loading = false;
        isRefreshing = false;
      });

      if (isUserManual) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Monitoring Data Refreshed Successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        isRefreshing = false;
      });

      if (isUserManual || loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeSaltingNow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finish Salting Now?'),
        content: const Text(
          'This will mark the salting process as completed immediately, '
          'even if the recommended duration has not fully elapsed. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Finish Now'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isCompleting = true;
    });

    try {
      await SaltingService.completeSalting(widget.batchId);
      await loadMonitoring();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salting marked as completed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCompleting = false;
        });
      }
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
          Image.asset('assets/images/logo.png', height: 55),
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

            const SizedBox(height: 20),

            if (m.status.toLowerCase() != 'completed')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isCompleting ? null : _completeSaltingNow,
                  icon: isCompleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isCompleting ? 'Finishing...' : 'Finish Salting Now',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0A5B8E),
                    side: const BorderSide(color: Color(0xFF0A5B8E)),
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

            if (m.status.toLowerCase() != 'completed')
              const SizedBox(height: 16),

            if (m.status.toLowerCase() == 'completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TimePredictionScreen(
                          batchId: m.batchId,
                          fishType: m.fishType,
                          initialWeightKg: m.currentWeight,
                          saltedCompleted: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text(
                    'Predict Time & Temperature',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A5B8E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Refresh Button
            MonitoringUpdateButton(
              isRefreshing: isRefreshing,
              onPressed: () => loadMonitoring(isUserManual: true),
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