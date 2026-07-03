import 'package:flutter/material.dart';

import '../models/processing_report_model.dart';
import '../services/processing_report_service.dart';

class EditBatchScreen extends StatefulWidget {
  final ProcessingReportModel batch;

  const EditBatchScreen({super.key, required this.batch});

  @override
  State<EditBatchScreen> createState() => _EditBatchScreenState();
}

class _EditBatchScreenState extends State<EditBatchScreen> {
  late TextEditingController fishController;
  late TextEditingController weightController;
  late TextEditingController statusController;

  @override
  void initState() {
    super.initState();

    fishController = TextEditingController(text: widget.batch.fishType);

    weightController = TextEditingController(
      text: widget.batch.rawWeight.toString(),
    );

    statusController = TextEditingController(text: widget.batch.status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Batch")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: fishController,
              decoration: const InputDecoration(labelText: "Fish Type"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: "Raw Weight"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: statusController,
              decoration: const InputDecoration(labelText: "Status"),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () async {
                try {
                  await ProcessingReportService.updateBatch(
                    batchId: widget.batch.batchId,
                    fishType: fishController.text,
                    rawWeight: double.parse(weightController.text),
                    status: statusController.text,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Batch Updated Successfully")),
                  );

                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },

              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
