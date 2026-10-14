import '../../services/Batch/batch_workflow_service.dart';
import 'package:flutter/material.dart';

import '../../widgets/Batch/colors.dart';
import '../drying/time_prediction_screen.dart';

/// Shown right after salting finishes for a batch (manually via "Finish
/// Salting Now" or naturally once the recommended duration elapses).
/// The only next step for a salted batch is predicting drying time and
/// temperature, then starting the drying process.
class SaltingCompletedScreen extends StatelessWidget {
  final String batchId;
  final String fishType;
  final double currentWeight;

  const SaltingCompletedScreen({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.currentWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Salting Completed',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Salting Completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Batch $batchId ($fishType) has finished salting. '
                'The next step is drying — predict the recommended '
                'temperature and total drying time before you start.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await BatchWorkflowService.updateStage('drying_prediction');
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TimePredictionScreen(
                          batchId: batchId,
                          fishType: fishType,
                          initialWeightKg: currentWeight,
                          saltedCompleted: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_fire_department_outlined),
                  label: const Text(
                    'Start Drying Process',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Dashboard'),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.stop_circle_outlined, size: 18, color: Colors.red),
                      label: const Text('End Process', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        BatchWorkflowService.showEndProcessDialog(context, batchId);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
