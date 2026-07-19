import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const SensorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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

          /// Icon
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(.12),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),

          const SizedBox(height: 14),

          /// Title
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xff1F2937),
            ),
          ),

          const SizedBox(height: 8),

          /// Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}