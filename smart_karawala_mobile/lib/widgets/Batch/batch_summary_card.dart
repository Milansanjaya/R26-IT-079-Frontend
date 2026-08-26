import 'package:flutter/material.dart';
import '../../models/batch_model.dart';
import '../../utils/weight_formatter.dart';

class BatchSummaryCard extends StatelessWidget {
  final BatchModel batch;
  final bool predicting;
  final VoidCallback onPredict;

  const BatchSummaryCard({
    super.key,
    required this.batch,
    required this.predicting,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF5FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                "Batch Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),

          const SizedBox(height: 20),

          _item("Batch ID", batch.batchId),

          _item("Fish Type", batch.fishType),

          _item("Raw Fish Weight", WeightFormatter.format(batch.rawWeight)),

          _item("Date", batch.date),

          _item("Location", batch.location),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: predicting ? null : onPredict,
              icon: predicting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.analytics),
              label: Text(
                predicting
                    ? "Predicting..."
                    : "Predict Waste",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [

          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}