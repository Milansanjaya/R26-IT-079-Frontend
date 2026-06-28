import 'package:flutter/material.dart';

import '../widgets/monitoring_status_card.dart';
import '../widgets/monitoring_recommendation_card.dart';
import '../widgets/monitoring_update_button.dart';
import '../widgets/monitoring_progress_card.dart';
import '../widgets/monitoring_weight_card.dart';
import '../widgets/monitoring_time_card.dart';
import '../widgets/monitoring_recommendation_card.dart';
import '../widgets/monitoring_header_card.dart';

class SaltingMonitoringScreen extends StatelessWidget {
  final String batchId;

  const SaltingMonitoringScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      appBar: AppBar(title: const Text("Salting Monitoring")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonitoringHeaderCard(
              batchId: batchId,
              fishType: "Thalapath",
              startTime: "19 May 2026\n11:05 AM",
              status: "In Progress",
            ),

            const SizedBox(height: 12),

            MonitoringStatusCard(status: "Normal"),

            const SizedBox(height: 16),

            Row(
              children: const [
                MonitoringProgressCard(progress: 64),

                SizedBox(width: 10),

                MonitoringWeightCard(weightLoss: 9.8, percentage: 10.3),

                SizedBox(width: 10),

                MonitoringTimeCard(remainingHours: 3.24),
              ],
            ),

            const SizedBox(height: 16),

            MonitoringRecommendationCard(status: "Normal"),

            const SizedBox(height: 16),

            MonitoringUpdateButton(
              onPressed: () {
                // TODO: Refresh monitoring data
              },
            ),
          ],
        ),
      ),
    );
  }
}
