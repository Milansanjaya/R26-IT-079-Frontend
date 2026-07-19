import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final double progress;

  const ProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0, 100);

    String status;

    if (value >= 100) {
      status = "Completed";
    } else if (value >= 80) {
      status = "Almost Done";
    } else {
      status = "In Progress";
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value / 100),
            duration: const Duration(milliseconds: 800),
            builder: (context, animatedValue, child) {
              return SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [

                    CircularProgressIndicator(
                      value: animatedValue,
                      strokeWidth: 9,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xff6C4AB6)),
                    ),

                    Center(
                      child: Text(
                        "${value.toInt()}%",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2D2D2D),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          const Text(
            "Drying Progress",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            status,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}