import 'package:flutter/material.dart';
import '../Batch/colors.dart';

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
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        label: const Text(
          "Refresh Monitoring Data",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}