import 'package:flutter/material.dart';

class MonitoringUpdateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MonitoringUpdateButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh),
        label: const Text(
          "Refresh Monitoring Data",
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff214E77),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}