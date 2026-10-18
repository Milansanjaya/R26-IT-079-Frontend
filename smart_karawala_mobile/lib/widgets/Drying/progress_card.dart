import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final double progress;
  final double currentWeight;
  final double initialWeight;
  final double targetWeight;

  const ProgressCard({
    super.key,
    required this.progress,
    required this.currentWeight,
    required this.initialWeight,
    required this.targetWeight,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final double safeProgress =
        progress.clamp(0.0, 100.0);

    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          SizedBox(
            height: 90,
            width: 90,

            child: Stack(
              fit: StackFit.expand,

              children: [
                CircularProgressIndicator(
                  value:
                      safeProgress / 100,

                  strokeWidth: 8,

                  backgroundColor:
                      Colors.grey.shade300,

                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    Color(0xff6B42C1),
                  ),
                ),

                Center(
                  child: Text(
                    "${safeProgress.toStringAsFixed(0)}%",

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            "Drying Progress",

            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            "${currentWeight.toStringAsFixed(3)} kg",

            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
