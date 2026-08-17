import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/Salt/salt_service.dart';
import '../../widgets/Batch/colors.dart';
import '../../widgets/Batch/dashboard_card.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../Add_Batch/add_new_batch_screen.dart';
import '../Salt/salt_prediction_screen.dart';
import '../Salt/salting_monitoring_screen.dart';
import '../Waste/waste_prediction_screen.dart';
import '../Waste/waste_traceability_screen.dart';
import '../admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'system_overview_dashboard_screen.dart';

class PanelItem {
  final String id;
  final String title;
  final IconData icon;
  final String category;
  final List<String> keywords;
  final void Function(BuildContext context) onTap;

  const PanelItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.keywords,
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
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "AI & ML",
    "Operations",
    "Monitoring & IoT",
    "Quality",
  ];

  late final List<PanelItem> _allPanels;

  @override
  void initState() {
    super.initState();
    _initPanels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initPanels() {
    _allPanels = [
      PanelItem(
        id: "add_batch",
        title: "Add Batch",
        icon: Icons.add_circle_outline_rounded,
        category: "Operations",
        keywords: [
          "add",
          "batch",
          "create",
          "fish",
          "raw",
          "weight",
          "karawala",
          "balaya",
          "hurulla",
          "thalapath",
          "kelawalla",
          "mora",
          "paraw",
          "linna",
          "salaya",
          "kumbalawa",
          "thora"
        ],
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const AddNewBatchScreen()),
        ),
      ),
      PanelItem(
        id: "waste_prediction",
        title: "Waste Prediction",
        icon: Icons.auto_delete_outlined,
        category: "AI & ML",
        keywords: [
          "waste",
          "prediction",
          "ai",
          "ml",
          "forecast",
          "recycle",
          "yield",
          "fish",
          "karawala"
        ],
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const WastePredictionScreen()),
        ),
      ),
      PanelItem(
        id: "salt_prediction",
        title: "Salt Prediction",
        icon: Icons.opacity_rounded,
        category: "AI & ML",
        keywords: [
          "salt",
          "prediction",
          "ml",
          "ai",
          "salting",
          "grams",
          "concentration",
          "ratio"
        ],
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const SaltPredictionScreen()),
        ),
      ),
      PanelItem(
        id: "traceability",
        title: "Traceability",
        icon: Icons.assignment_outlined,
        category: "Operations",
        keywords: [
          "traceability",
          "trace",
          "qr",
          "batch",
          "history",
          "origin",
          "log",
          "tracking"
        ],
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const WasteTraceabilityScreen()),
        ),
      ),
      PanelItem(
        id: "salt_monitoring",
        title: "Salt Monitoring",
        icon: Icons.water_drop_outlined,
        category: "Monitoring & IoT",
        keywords: [
          "salt",
          "monitoring",
          "realtime",
          "sensor",
          "brine",
          "salinity",
          "water"
        ],
        onTap: (ctx) async {
          try {
            final batch = await SaltService.getLatestBatch();
            if (!ctx.mounted) return;
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => SaltingMonitoringScreen(batchId: batch.batchId),
              ),
            );
          } catch (e) {
            if (!ctx.mounted) return;
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => const SaltingMonitoringScreen(batchId: "B100808"),
              ),
            );
          }
        },
      ),
      PanelItem(
        id: "drying",
        title: "Drying",
        icon: Icons.wb_sunny_outlined,
        category: "Monitoring & IoT",
        keywords: ["drying", "sun", "solar", "temperature", "heat", "hours"],
        onTap: (ctx) => _showDryingInfoModal(ctx),
      ),
      PanelItem(
        id: "drying_control",
        title: "Drying Control",
        icon: Icons.tune_rounded,
        category: "Monitoring & IoT",
        keywords: ["drying", "control", "fan", "airflow", "chamber", "humidity"],
        onTap: (ctx) => _showDryingControlModal(ctx),
      ),
      PanelItem(
        id: "iot_status",
        title: "IoT Status",
        icon: Icons.memory_outlined,
        category: "Monitoring & IoT",
        keywords: [
          "iot",
          "status",
          "sensors",
          "telemetry",
          "hardware",
          "devices",
          "online"
        ],
        onTap: (ctx) => _showIotStatusModal(ctx),
      ),
      PanelItem(
        id: "alerts",
        title: "Alerts",
        icon: Icons.notifications_none_rounded,
        category: "Operations",
        keywords: [
          "alerts",
          "notifications",
          "warnings",
          "events",
          "thresholds"
        ],
        onTap: (ctx) => _showAlertsModal(ctx),
      ),
      PanelItem(
        id: "live_camera",
        title: "Live Camera",
        icon: Icons.videocam_outlined,
        category: "Quality",
        keywords: [
          "camera",
          "live",
          "video",
          "stream",
          "feed",
          "visual",
          "monitoring"
        ],
        onTap: (ctx) => _showLiveCameraModal(ctx),
      ),
      PanelItem(
        id: "defects",
        title: "Defects",
        icon: Icons.search_outlined,
        category: "Quality",
        keywords: [
          "defects",
          "vision",
          "ai",
          "quality",
          "discoloration",
          "spoilage"
        ],
        onTap: (ctx) => _showDefectsModal(ctx),
      ),
      PanelItem(
        id: "inspection",
        title: "Inspection",
        icon: Icons.history_rounded,
        category: "Quality",
        keywords: [
          "inspection",
          "audit",
          "history",
          "compliance",
          "certification",
          "standard"
        ],
        onTap: (ctx) => _showInspectionModal(ctx),
      ),
      PanelItem(
        id: "admin_panel",
        title: "Admin Panel",
        icon: Icons.admin_panel_settings_outlined,
        category: "Operations",
        keywords: [
          "admin",
          "panel",
          "overview",
          "system",
          "settings",
          "management"
        ],
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        ),
      ),
    ];
  }

  List<PanelItem> get _filteredPanels {
    final query = _searchQuery.trim().toLowerCase();
    return _allPanels.where((panel) {
      final matchesCategory =
          _selectedCategory == "All" || panel.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      final titleMatch = panel.title.toLowerCase().contains(query);
      final keywordMatch =
          panel.keywords.any((kw) => kw.toLowerCase().contains(query));
      final categoryMatch = panel.category.toLowerCase().contains(query);

      return titleMatch || keywordMatch || categoryMatch;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune_rounded, color: AppColors.primary),
                          SizedBox(width: 10),
                          Text(
                            "Filter Modules",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Select Category",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: const Color(0xff0A5B8E),
                        backgroundColor: const Color(0xffF2F8FD),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xff0A5B8E)
                                : const Color(0xffD0E6F7),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setSheetState(() => _selectedCategory = cat);
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() => _selectedCategory = "All");
                            setState(() => _selectedCategory = "All");
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xff0A5B8E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Reset",
                            style: TextStyle(
                              color: Color(0xff0A5B8E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0A5B8E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Apply Filter",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Interactive Feature Modals ---

  void _showDryingInfoModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFeatureSheet(
        title: "Solar Drying Status",
        icon: Icons.wb_sunny_outlined,
        iconColor: Colors.orange,
        children: [
          _buildMetricRow("Chamber Temp", "38.5 °C", Colors.orange),
          _buildMetricRow("Ambient Humidity", "42%", Colors.blue),
          _buildMetricRow("Drying Time Elapsed", "4.5 hrs", Colors.green),
          _buildMetricRow("Target Moisture", "15.0%", Colors.purple),
        ],
      ),
    );
  }

  void _showDryingControlModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFeatureSheet(
        title: "Drying Bed Controls",
        icon: Icons.tune_rounded,
        iconColor: const Color(0xff0A5B8E),
        children: [
          _buildControlToggle("Exhaust Fans #1 & #2", true),
          _buildControlToggle("Solar Dehumidifier", true),
          _buildControlToggle("Auto-Ventilation Shutter", false),
          _buildMetricRow("Air Flow Speed", "2.4 m/s", Colors.blue),
        ],
      ),
    );
  }

  void _showIotStatusModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFeatureSheet(
        title: "IoT Node Telemetry",
        icon: Icons.memory_outlined,
        iconColor: Colors.teal,
        children: [
          _buildStatusRow("Salting Tank Probe #A", "ONLINE", Colors.green),
          _buildStatusRow("Drying Chamber Node #B", "ONLINE", Colors.green),
          _buildStatusRow("Load Cell Sensor #C", "ONLINE", Colors.green),
          _buildStatusRow("MQTT Broker Stream", "CONNECTED", Colors.green),
        ],
      ),
    );
  }

  void _showAlertsModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFeatureSheet(
        title: "Operations Alerts",
        icon: Icons.notifications_none_rounded,
        iconColor: Colors.amber.shade800,
        children: [
          _buildAlertItem(
            "Batch B100808 Salting Complete",
            "Optimal brine concentration reached (3.2%)",
            "5 mins ago",
            Colors.green,
          ),
          _buildAlertItem(
            "Recycling Partner Notified",
            "Ocean Recyclers dispatched for waste pickup (15.75 kg)",
            "1 hr ago",
            Colors.blue,
          ),
          _buildAlertItem(
            "Drying Chamber #2 Ready",
            "Target humidity (45%) maintained",
            "2 hrs ago",
            Colors.orange,
          ),
        ],
      ),
    );
  }

  void _showLiveCameraModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFeatureSheet(
        title: "Live Quality Inspection Camera",
        icon: Icons.videocam_outlined,
        iconColor: Colors.indigo,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.videocam, size: 48, color: Colors.white54),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            size: 10, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "LIVE CAM #1",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 12,
                  child: Text(
                    "Drying Bed Inspection Feed • 1080p 60FPS",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDefectsModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFeatureSheet(
        title: "AI Defect Detection",
        icon: Icons.search_outlined,
        iconColor: Colors.purple,
        children: [
          _buildMetricRow("Batch Quality Score", "98.4%", Colors.green),
          _buildMetricRow("Defect Rate", "1.6% (Low)", Colors.green),
          _buildMetricRow("Discoloration Index", "Normal", Colors.blue),
          _buildMetricRow("Certification Status", "GRADE A - PASSED", Colors.teal),
        ],
      ),
    );
  }

  void _showInspectionModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildFeatureSheet(
        title: "Inspection History & Audit",
        icon: Icons.history_rounded,
        iconColor: const Color(0xff0A5B8E),
        children: [
          _buildStatusRow("Daily HACCP Audit", "PASSED", Colors.green),
          _buildStatusRow("Moisture Inspection", "COMPLIANT", Colors.green),
          _buildStatusRow("Salt Level Sensor Calibration", "VERIFIED", Colors.green),
          _buildStatusRow("Traceability Seal Generation", "ACTIVE", Colors.blue),
        ],
      ),
    );
  }

  Widget _buildFeatureSheet({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlToggle(String label, bool initialVal) {
    return StatefulBuilder(
      builder: (context, setStateToggle) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
              Switch.adaptive(
                value: initialVal,
                activeColor: const Color(0xff0A5B8E),
                onChanged: (v) {
                  setStateToggle(() => initialVal = v);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertItem(
      String title, String desc, String time, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, color: iconColor, size: 10),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // --- Home Screen Body ---

  Widget _buildHomeBody(BuildContext context) {
    final panels = _filteredPanels;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu,
                      size: 22, color: AppColors.primary),
                ),
                Image.asset('assets/images/logo.png', height: 70),
              ],
            ),

            const SizedBox(height: 20),

            // Greeting & Subtitle
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final displayName = (auth.user?.fullName.isNotEmpty == true)
                    ? auth.user!.fullName
                    : "jayani";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back,",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Search Bar & Filter layout
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search dry fish, modules, predictions...",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.primary, size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    color: Colors.grey, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = "";
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedCategory != "All"
                          ? const Color(0xff0A5B8E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.tune,
                      color: _selectedCategory != "All"
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            if (_selectedCategory != "All") ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff0A5B8E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Category: $_selectedCategory",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0A5B8E),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = "All";
                            });
                          },
                          child: const Icon(Icons.close,
                              size: 14, color: Color(0xff0A5B8E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Title for Admin Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dashboard Panels",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  "${panels.length} available",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Grid Actions or Empty State
            Expanded(
              child: panels.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No panels found for '$_searchQuery'",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Try searching for 'batch', 'salt', 'waste', or 'drying'",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                                _selectedCategory = "All";
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text("Clear Search & Filters"),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      itemCount: panels.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final panel = panels[index];
                        return GestureDetector(
                          onTap: () => panel.onTap(context),
                          child: DashboardCard(
                            icon: panel.icon,
                            title: panel.title,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeBody(context);
      case 1:
        return const AdminProfileScreen();
      default:
        return _buildHomeBody(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(context),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
