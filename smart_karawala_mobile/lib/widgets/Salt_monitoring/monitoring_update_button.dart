import 'package:flutter/material.dart';
import '../Batch/colors.dart';

class MonitoringUpdateButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isRefreshing;

  const MonitoringUpdateButton({
    super.key,
    required this.onPressed,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isRefreshing ? null : onPressed,
        icon: isRefreshing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.refresh_rounded, color: Colors.white),
        label: Text(
          isRefreshing ? "Refreshing..." : "Refresh Monitoring Data",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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