import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //------------------------------------------------
        // Search + Filter
        //------------------------------------------------
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  style: const TextStyle(fontSize: 13),

                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xff214E77),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              width: 95,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: const Text("Filter", style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff214E77),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        //------------------------------------------------
        // Filters
        //------------------------------------------------
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: "All Dates",
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "All Dates",
                    child: Text("All Dates"),
                  ),
                  DropdownMenuItem(
                    value: "Last 7 Days",
                    child: Text("Last 7 Days"),
                  ),
                  DropdownMenuItem(
                    value: "Last 30 Days",
                    child: Text("Last 30 Days"),
                  ),
                  DropdownMenuItem(
                    value: "This Month",
                    child: Text("This Month"),
                  ),
                  DropdownMenuItem(
                    value: "Last Month",
                    child: Text("Last Month"),
                  ),
                ],
                onChanged: (_) {},
              ),
            ),

            const SizedBox(width: 8),

            Expanded(child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: "All Fish Types",
              style: const TextStyle(fontSize: 12, color: Colors.black),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "All Fish Types",
                  child: Text("All Fish Types"),
                ),
                DropdownMenuItem(value: "Salaya", child: Text("Salaya")),
                DropdownMenuItem(value: "Hurulla", child: Text("Hurulla")),
                DropdownMenuItem(value: "Thora", child: Text("Thora")),
                DropdownMenuItem(value: "Balaya", child: Text("Balaya")),
                DropdownMenuItem(value: "Kelawalla", child: Text("Kelawalla")),
              ],
              onChanged: onFishChanged,
            )
            ),

            const SizedBox(width: 8),

            Expanded(child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: "All Status",
              style: const TextStyle(fontSize: 12, color: Colors.black),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "All Status",
                  child: Text("All Status"),
                ),
                DropdownMenuItem(value: "Completed", child: Text("Completed")),
                DropdownMenuItem(
                  value: "In Progress",
                  child: Text("In Progress"),
                ),
                DropdownMenuItem(
                  value: "Not Started",
                  child: Text("Not Started"),
                ),
              ],
              onChanged: onStatusChanged,
            )
            ),
          ],
        ),
      ],
    );
  }
}
