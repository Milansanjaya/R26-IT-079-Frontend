import 'package:flutter/material.dart';

class StatusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool status;

  const StatusTile({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
  });

  Color get iconColor {
    switch (title) {
      case "Heater":
        return Colors.red;
      case "Fan":
        return Colors.indigo;
      case "Light":
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          /// Icon
          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withOpacity(.12),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          /// Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  status
                      ? "Currently Running"
                      : "Currently Stopped",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          /// Status
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: status
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [

                Icon(
                  Icons.circle,
                  size: 10,
                  color: status
                      ? Colors.green
                      : Colors.red,
                ),

                const SizedBox(width: 6),

                Text(
                  status ? "ON" : "OFF",
                  style: TextStyle(
                    color: status
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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