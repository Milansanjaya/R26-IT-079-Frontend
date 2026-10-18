import '../../services/Batch/batch_workflow_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/Salt/salt_service.dart';
import '../Add_Batch/add_new_batch_screen.dart';
import '../Waste/waste_prediction_screen.dart';
import '../Waste/waste_traceability_screen.dart';
import '../Salt/salt_prediction_screen.dart';
import '../Salt/salting_monitoring_screen.dart';
import '../drying/drying_dashboard_screen.dart';
import '../Batch_admin/batch_records_dashboard_screen.dart';
import '../monitoring/monitoring_screen.dart';
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
  Map<String, dynamic>? _activeBatch;

  @override
  void initState() {
    super.initState();
    _loadActiveBatch();
  }

  Future<void> _loadActiveBatch() async {
    final active = await BatchWorkflowService.getActiveBatch();
    if (mounted) {
      setState(() {
        _activeBatch = active;
      });
    }
  }

  void _showActiveBatchRunningDialog(BuildContext ctx, Map<String, dynamic> active) {
    final batchId = active['batchId'] ?? '';
    final fishType = active['fishType'] ?? 'Fish';
    final stage = active['stage'] ?? 'waste_prediction';
    final stageName = BatchWorkflowService.getStageDisplayName(stage);

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_alt, color: Colors.orange.shade800, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'Batch In Progress',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch $batchId ($fishType) is currently running.',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_run, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stageName,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A batch is currently in progress. You can jump directly to its current running stage, or end the process to begin a new batch.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              BatchWorkflowService.showEndProcessDialog(context, batchId)
                  .then((_) => _loadActiveBatch());
            },
            child: const Text('End Process', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              BatchWorkflowService.navigateToActiveStage(context, active);
            },
            label: const Text('Go to Running Stage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Admin',
    'Monitoring',
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
        onTap: (ctx) async {
          final active = await BatchWorkflowService.getActiveBatch();
          if (active != null && active['isActive'] == true) {
            _showActiveBatchRunningDialog(ctx, active);
          } else {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => const AddNewBatchScreen(),
              ),
            ).then((_) => _loadActiveBatch());
          }
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
        title: 'Time Prediction',
        category: 'Drying',
        icon: Icons.timer_outlined,
        iconColor: Colors.deepPurple,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const BatchRecordsDashboardScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Verification Station',
        category: 'Monitoring',
        icon: Icons.sensors,
        iconColor: Colors.teal,
        onTap: (ctx) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => const MonitoringScreen(),
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
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final user = auth.user;
                        final name = (user?.fullName != null && user!.fullName.isNotEmpty)
                            ? user.fullName
                            : 'Admin';
                        return Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        );
                      },
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
            if (_activeBatch != null && _activeBatch!['isActive'] == true) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff0A5B8E), Color(0xff1872A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff0A5B8E).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'CURRENTLY PROCESSING BATCH',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _activeBatch!['batchId'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${_activeBatch!['fishType']} (${_activeBatch!['rawWeight']} kg)",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      BatchWorkflowService.getStageDisplayName(_activeBatch!['stage'] ?? ''),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow, size: 18, color: Color(0xff0A5B8E)),
                            label: const Text(
                              'Resume Stage',
                              style: TextStyle(
                                color: Color(0xff0A5B8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              BatchWorkflowService.navigateToActiveStage(context, _activeBatch!);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.stop_circle_outlined, size: 18, color: Colors.white),
                          label: const Text(
                            'End Process',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onPressed: () {
                            BatchWorkflowService.showEndProcessDialog(context, _activeBatch!['batchId'] ?? '')
                                .then((_) => _loadActiveBatch());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
