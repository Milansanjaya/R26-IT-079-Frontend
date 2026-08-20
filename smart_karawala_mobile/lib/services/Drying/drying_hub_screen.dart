import 'package:flutter/material.dart';
import '../../screens/admin/admin_home_screen.dart';


import '../../core/constants/app_colors.dart';
import '../../models/drying_model.dart';
import 'drying_service.dart';
import '../../widgets/Drying/drying_empty_state.dart';
import '../../widgets/Drying/drying_process_card.dart';

/// Dedicated "Drying" screen reached from the admin dashboard card.
///
/// Uses the same modern drying experience as the batch details page: it hosts
/// the [DryingProcessCard] for whichever batch is currently drying. If no batch
/// is drying, it offers to start the latest batch (the one placed in the oven).
class DryingHubScreen extends StatefulWidget {
  const DryingHubScreen({super.key});

  @override
  State<DryingHubScreen> createState() => _DryingHubScreenState();
}

class _DryingHubScreenState extends State<DryingHubScreen> {
  bool _loading = true;
  bool _starting = false;
  ActiveDryingBatch? _active;
  String? _activeBatchId; // batch to render the card for (after start too)
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkActive();
  }

  Future<void> _checkActive() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final active = await DryingService.getActiveBatch();
      if (!mounted) return;
      setState(() {
        _active = active;
        _activeBatchId = active?.batchId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _clean(e);
      });
    }
  }

  Future<void> _startLatestBatch() async {
    setState(() => _starting = true);
    try {
      // The most recently created batch is the one placed in the oven.
      final batchId = await DryingService.getLatestBatchId();
      final started = await DryingService.startDrying(batchId);
      if (!mounted) return;
      setState(() {
        _activeBatchId = started.batchId;
        _starting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _starting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_clean(e)), backgroundColor: AppColors.error),
      );
    }
  }

  String _clean(Object e) => e.toString().replaceFirst("Exception: ", "").trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Drying",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminHomeScreen(),
                ),
              );
            },
            child: Image.asset('assets/images/logo.png', height: 55),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Service unreachable.
    if (_error != null && _activeBatchId == null) {
      return DryingEmptyState(
        icon: Icons.cloud_off_rounded,
        title: "Can't reach the drying service",
        message: _error!,
        actionLabel: "Try again",
        onAction: _checkActive,
      );
    }

    // A batch is drying (or was just started) -> show the modern card.
    if (_activeBatchId != null) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _checkActive,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            if (_active != null) _batchSummary(_active!),
            DryingProcessCard(
              // Rebuild the card if the active batch changes.
              key: ValueKey(_activeBatchId),
              batchId: _activeBatchId!,
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    // No active batch -> offer to start the latest one.
    return DryingEmptyState(
      icon: Icons.wb_sunny_outlined,
      title: "No batch is drying yet",
      message:
          "Once a batch is placed in the drying oven, start drying to begin "
          "predicting completion time and spoilage risk.",
      actionLabel: _starting ? "Starting…" : "Start Drying Latest Batch",
      onAction: _starting ? () {} : _startLatestBatch,
    );
  }

  /// Small identity banner above the drying card on this dedicated screen.
  Widget _batchSummary(ActiveDryingBatch b) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.batchId,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  b.fishType.isEmpty
                      ? "In drying oven"
                      : "${b.fishType[0].toUpperCase()}${b.fishType.substring(1)} • ${b.initialWeightKg.toStringAsFixed(2)} kg",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
