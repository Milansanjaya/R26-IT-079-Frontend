import 'package:flutter/material.dart';

class MonitoringStatusCard extends StatelessWidget {
  final String status;

  const MonitoringStatusCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    Color bgColor;
    String title;
    String subtitle;

    switch (status) {
      case "Completed":
        iconColor = Colors.green;
        bgColor = const Color(0xffF1FFF3);
        title = "Status: Completed";
        subtitle = "Salting process has been completed successfully.";
        break;

      case "Warning":
        iconColor = Colors.orange;
        bgColor = const Color(0xffFFF8E8);
        title = "Status: Warning";
        subtitle = "Weight loss is outside the normal range.";
        break;

      default:
        iconColor = Colors.green;
        bgColor = const Color(0xffF5FFF4);
        title = "Status: Normal";
        subtitle =
            "Salting process is progressing as expected.\nWeight loss and time are within the normal range.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor,
            child: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}