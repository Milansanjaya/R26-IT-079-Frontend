import 'package:flutter/material.dart';
import '../Batch/colors.dart';

class ReportFilterSection extends StatelessWidget {
  final Function(String) onSearch;
  final Function(String?) onFishChanged;
  final Function(String?) onStatusChanged;

  const ReportFilterSection({
    super.key,
    required this.onSearch,
    required this.onFishChanged,
    required this.onStatusChanged,
  });

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  style: const TextStyle(fontSize: 13),
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: "Search report details...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFC),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 90,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_alt_outlined, size: 16),
                label: const Text("Filter", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Dropdowns Row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: "All Dates",
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: _inputDecoration("Date", Icons.calendar_today_outlined),
                items: const [
                  DropdownMenuItem(value: "All Dates", child: Text("All Dates")),
                  DropdownMenuItem(value: "Last 7 Days", child: Text("7 Days")),
                  DropdownMenuItem(value: "Last 30 Days", child: Text("30 Days")),
                  DropdownMenuItem(value: "This Month", child: Text("This Month")),
                ],
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: "All Fish Types",
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: _inputDecoration("Fish Type", Icons.set_meal_outlined),
                items: const [
                  DropdownMenuItem(value: "All Fish Types", child: Text("All Fish Types")),
                  DropdownMenuItem(value: "Salaya", child: Text("Salaya")),
                  DropdownMenuItem(value: "Hurulla", child: Text("Hurulla")),
                  DropdownMenuItem(value: "Thora", child: Text("Thora")),
                  DropdownMenuItem(value: "Balaya", child: Text("Balaya")),
                ],
                onChanged: onFishChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: "All Status",
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: _inputDecoration("Status", Icons.verified_user_outlined),
                items: const [
                  DropdownMenuItem(value: "All Status", child: Text("All Status")),
                  DropdownMenuItem(value: "Completed", child: Text("Completed")),
                  DropdownMenuItem(value: "In Progress", child: Text("In Progress")),
                ],
                onChanged: onStatusChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
