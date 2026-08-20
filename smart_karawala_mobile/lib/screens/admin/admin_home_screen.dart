import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/Salt/salt_service.dart';
import '../Add_Batch/add_new_batch_screen.dart';
import '../Waste/waste_prediction_screen.dart';
import '../Waste/waste_traceability_screen.dart';
import '../Salt/salt_prediction_screen.dart';
import '../Salt/salting_monitoring_screen.dart';
import '../Drying/drying_dashboard_screen.dart';
import '../admin_dashboard_screen.dart';

import 'admin_profile_screen.dart';

class DashboardItem {
  final String title;
  final String category;
  final IconData icon;
  final Color iconColor;
  final void Function(BuildContext context) onTap;

  const DashboardItem({
    required this.title,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Admin',
    'Batch',
    'Waste',
    'Salt',
    'Drying',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DashboardItem> _getDashboardItems(BuildContext context) {
    return [
      DashboardItem(
        title: 'Add New Batch',
        category: 'Batch',
        icon: Icons.add_circle_outline,
        iconColor: Colors.blue,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const AddNewBatchScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Waste Prediction',
        category: 'Waste',
        icon: Icons.bar_chart,
        iconColor: Colors.teal,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const WastePredictionScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Salt Prediction',
        category: 'Salt',
        icon: Icons.grain,
        iconColor: Colors.orange,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const SaltPredictionScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Waste & Traceability',
        category: 'Waste',
        icon: Icons.assignment,
        iconColor: Colors.green,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const WasteTraceabilityScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Salt Monitoring',
        category: 'Salt',
        icon: Icons.water_drop,
        iconColor: Colors.indigo,
        onTap: (ctx) async {
          final batch = await SaltService.getLatestBatch();
          if (!mounted) return;

          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => SaltingMonitoringScreen(batchId: batch.batchId),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Drying Dashboard',
        category: 'Drying',
        icon: Icons.wb_sunny,
        iconColor: Colors.pinkAccent,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const DryingDashboardScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Admin Dashboard',
        category: 'Admin',
        icon: Icons.manage_accounts,
        iconColor: Colors.deepPurple,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen(),
            ),
          );
        },
      ),
    ];
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Panels',
                        style: TextStyle(
                          fontSize: 18,
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                          setModalState(() {});
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dashboardTile(DashboardItem item, BuildContext context) {
    return GestureDetector(
      onTap: () => item.onTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 30, color: item.iconColor),
            const SizedBox(height: 10),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final allItems = _getDashboardItems(context);

    final filteredItems = allItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sanjaya',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminHomeScreen(),
                      ),
                    );
                  },
                  child: Image.asset('assets/images/logo.png', height: 56),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search panels...',
                        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: AppColors.hint),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppColors.hint),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showFilterModal,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedCategory != 'All'
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedCategory != 'All'
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.tune,
                          color: _selectedCategory != 'All'
                              ? AppColors.primary
                              : AppColors.primary,
                        ),
                        if (_selectedCategory != 'All')
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedCategory != 'All' || _searchController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_selectedCategory != 'All')
                    Chip(
                      label: Text('Category: $_selectedCategory'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = 'All';
                        });
                      },
                    ),
                  if (_searchController.text.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('"${_searchController.text}"'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard Panels',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${filteredItems.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No matching dashboard panels found',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: filteredItems
                    .map((item) => _dashboardTile(item, context))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentIndex == 0 ? _buildHomeBody(context) : const AdminProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[800],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
