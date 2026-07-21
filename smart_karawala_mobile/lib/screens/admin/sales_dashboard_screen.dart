import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import 'add_product_screen.dart';
import 'manage_orders_screen.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  String selectedRange = "Month";
  int _currentIndex = 0;

  final List<Map<String, dynamic>> stats = [
    {
      "title": "Gross Profit",
      "value": "\$18,750",
      "trend": "↑ 10.4%",
      "isPositive": true,
      "icon": Icons.account_balance_wallet_outlined,
      "color": Colors.green,
    },
    {
      "title": "Expenses",
      "value": "\$5,250",
      "trend": "↓ -2.1%",
      "isPositive": false,
      "icon": Icons.shopping_bag_outlined,
      "color": Colors.red,
    },
    {
      "title": "Net Profit",
      "value": "\$13,500",
      "trend": "↑ 14.5%",
      "isPositive": true,
      "icon": Icons.show_chart_rounded,
      "color": Colors.blue,
    },
    {
      "title": "Profit Margin",
      "value": "38.8%",
      "trend": "↑ 3.6%",
      "isPositive": true,
      "icon": Icons.pie_chart_outline_rounded,
      "color": Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> products = [
    {
      "rank": "1",
      "name": "Dry Mora (Shark)",
      "weight": "1kg",
      "sold": "532 Sold",
      "revenue": "\$7,980.00",
      "trend": "↑ 15.5%",
      "isPositive": true,
      "image": "assets/images/mora.jpg",
    },
    {
      "rank": "2",
      "name": "Balaya (Tuna)",
      "weight": "1kg",
      "sold": "421 Sold",
      "revenue": "\$6,742.00",
      "trend": "↑ 8.3%",
      "isPositive": true,
      "image": "assets/images/balaya.jpg",
    },
    {
      "rank": "3",
      "name": "Salmon Dry",
      "weight": "1kg",
      "sold": "312 Sold",
      "revenue": "\$4,992.00",
      "trend": "↑ 12.7%",
      "isPositive": true,
      "image": "assets/images/all.jpg",
    },
    {
      "rank": "4",
      "name": "Kelawalla (Skipjack)",
      "weight": "1kg",
      "sold": "298 Sold",
      "revenue": "\$4,470.00",
      "trend": "↑ 6.8%",
      "isPositive": true,
      "image": "assets/images/kelawalla.webp",
    },
    {
      "rank": "5",
      "name": "Dry Katta",
      "weight": "1kg",
      "sold": "180 Sold",
      "revenue": "\$2,880.00",
      "trend": "↓ -1.2%",
      "isPositive": false,
      "image": "assets/images/karawala.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Notification Icon with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 26),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text(
                    "3",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Profile Avatar
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage("assets/images/profile.jpg"),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Earnings Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Title + Dropdown Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Earnings Overview",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF6F8FC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedRange,
                            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
                            items: const [
                              DropdownMenuItem(value: "Week", child: Text("Week")),
                              DropdownMenuItem(value: "Month", child: Text("Month")),
                              DropdownMenuItem(value: "Year", child: Text("Year")),
                            ],
                            onChanged: (val) {
                              setState(() {
                                selectedRange = val!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Horizontal Earning Stats Cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: stats.map((st) {
                        return Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                st["title"],
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                st["value"],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                st["trend"],
                                style: TextStyle(
                                  color: st["isPositive"] ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // View Full Report Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xffF4F7FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "View Full Report",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                            ),
                            Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Best Selling Products Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Best Selling Products",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        child: const Text("View All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Products List
                  Column(
                    children: products.map((pr) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            // Rank Number
                            Text(
                              pr["rank"],
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 14),
                            ),
                            const SizedBox(width: 14),
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                pr["image"],
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product Details (Title & Subtitle)
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pr["name"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    pr["weight"],
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Sold Count & Revenue
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pr["sold"],
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    pr["revenue"],
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Trend tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: pr["isPositive"] ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pr["trend"],
                                style: TextStyle(
                                  color: pr["isPositive"] ? Colors.green.shade800 : Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
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
