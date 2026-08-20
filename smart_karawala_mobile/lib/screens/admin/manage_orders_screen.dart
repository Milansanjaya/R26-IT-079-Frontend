import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import 'add_product_screen.dart';
import 'sales_dashboard_screen.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  int _currentIndex = 2;
  String selectedFilter = "All";
  String searchQuery = "";

  final List<String> filters = ["All", "Pending", "Processing", "Shipped", "Delivered"];

  final List<Map<String, dynamic>> allOrders = [
    {
      "id": "ORD-2025-001",
      "date": "May 12, 2025 • 02:30 PM",
      "status": "Delivered",
      "total": "\$250.00",
      "customer": "Kamal Perera",
      "items": "2x Dry Mora (1kg), 1x Salted Balaya (500g)",
      "address": "No. 45, Galle Road, Colombo 03",
    },
    {
      "id": "ORD-2025-002",
      "date": "May 12, 2025 • 11:15 AM",
      "status": "Processing",
      "total": "\$180.00",
      "customer": "Nimal Fernando",
      "items": "3x Balaya (1kg)",
      "address": "Main Street, Negombo",
    },
    {
      "id": "ORD-2025-003",
      "date": "May 11, 2025 • 09:45 PM",
      "status": "Pending",
      "total": "\$320.00",
      "customer": "Sunil Silva",
      "items": "2x Salmon Dry (1kg), 2x Dry Katta (1kg)",
      "address": "Beach Road, Matara",
    },
    {
      "id": "ORD-2025-004",
      "date": "May 10, 2025 • 05:20 PM",
      "status": "Shipped",
      "total": "\$420.00",
      "customer": "Anura Wickrama",
      "items": "4x Kelawalla Skipjack (1kg)",
      "address": "Harbour Road, Trincomalee",
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    return allOrders.where((order) {
      final matchesFilter = selectedFilter == "All" || order["status"] == selectedFilter;
      final matchesSearch = order["id"].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          order["customer"].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case "Delivered":
        return const Color(0xFFE8F5E9);
      case "Processing":
        return const Color(0xFFE3F2FD);
      case "Pending":
        return const Color(0xFFFFF3E0);
      case "Shipped":
        return const Color(0xFFF3E5F5);
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case "Delivered":
        return Colors.green.shade800;
      case "Processing":
        return Colors.blue.shade800;
      case "Pending":
        return Colors.orange.shade800;
      case "Shipped":
        return Colors.purple.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  void _showOrderDetailsModal(Map<String, dynamic> order) {
    String currentStatus = order["status"];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order["id"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    order["date"],
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  _detailRow("Customer", order["customer"]),
                  const SizedBox(height: 8),
                  _detailRow("Delivery Address", order["address"]),
                  const SizedBox(height: 8),
                  _detailRow("Items", order["items"]),
                  const SizedBox(height: 8),
                  _detailRow("Total Amount", order["total"], isBold: true),

                  const SizedBox(height: 20),
                  const Text(
                    "Update Order Status",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentStatus,
                        isExpanded: true,
                        items: filters
                            .where((f) => f != "All")
                            .map((st) => DropdownMenuItem(
                                  value: st,
                                  child: Text(
                                    st,
                                    style: TextStyle(
                                      color: _getStatusTextColor(st),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            setModalState(() {
                              currentStatus = newStatus;
                            });
                            setState(() {
                              order["status"] = newStatus;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Order ${order["id"]} status updated to '$currentStatus'"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          "Manage Orders",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search & Filter funnel row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      style: const TextStyle(fontSize: 13),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search orders...",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_outlined, color: AppColors.primary, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Horizontal scrollable chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final f = filters[index];
                final isSelected = selectedFilter == f;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = f;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      f,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Orders list
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      "No orders found",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.grey.shade100, height: 24),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order["id"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order["date"],
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Tag
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusBgColor(order["status"]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                order["status"],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(order["status"]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Total & View link
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  order["total"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _showOrderDetailsModal(order),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "View ",
                                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                      Icon(Icons.chevron_right_rounded, size: 14, color: Colors.blue),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SalesDashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: "Add Product",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: "Manage Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded),
            label: "Sales Analytics",
          ),
        ],
      ),
    );
  }
}
