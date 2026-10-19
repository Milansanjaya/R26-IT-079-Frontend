import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

import '../../screens/Waste/waste_prediction_screen.dart';
import '../../screens/Salt/salt_prediction_screen.dart';
import '../../screens/Salt/salting_monitoring_screen.dart';
import '../../screens/Salt/salting_completed_screen.dart';
import '../../screens/drying/time_prediction_screen.dart';
import '../../screens/drying/drying_dashboard_screen.dart';
import '../../screens/monitoring/monitoring_screen.dart';
import '../../screens/admin/admin_home_screen.dart';

class BatchWorkflowService {
  static const String _keyBatchId = "active_workflow_batch_id";
  static const String _keyFishType = "active_workflow_fish_type";
  static const String _keyRawWeight = "active_workflow_raw_weight";
  static const String _keyStage = "active_workflow_stage";
  static const String _keyIsActive = "active_workflow_is_active";
  static const String _keyExtraData = "active_workflow_extra_data";

  static String get batchApiUrl => AppConfig.batchesBaseUrl;
  static String get dryingApiUrl => AppConfig.dryingBaseUrl;

  static final Map<String, dynamic> _fallbackMemory = {};

  /// Save newly created batch and set workflow active
  static Future<void> saveActiveBatch({
    required String batchId,
    required String fishType,
    required double rawWeight,
    required String stage,
    Map<String, dynamic>? extraData,
  }) async {
    _fallbackMemory[_keyBatchId] = batchId;
    _fallbackMemory[_keyFishType] = fishType;
    _fallbackMemory[_keyRawWeight] = rawWeight;
    _fallbackMemory[_keyStage] = stage;
    _fallbackMemory[_keyIsActive] = true;
    if (extraData != null) {
      _fallbackMemory[_keyExtraData] = jsonEncode(extraData);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyBatchId, batchId);
      await prefs.setString(_keyFishType, fishType);
      await prefs.setDouble(_keyRawWeight, rawWeight);
      await prefs.setString(_keyStage, stage);
      await prefs.setBool(_keyIsActive, true);
      if (extraData != null) {
        await prefs.setString(_keyExtraData, jsonEncode(extraData));
      }
    } catch (e) {
      debugPrint('[Workflow] saveActiveBatch prefs error: $e');
    }
  }

  /// Update the stage of the currently running batch
  static Future<void> updateStage(String stage, {Map<String, dynamic>? extraData}) async {
    _fallbackMemory[_keyStage] = stage;
    if (extraData != null) {
      _fallbackMemory[_keyExtraData] = jsonEncode(extraData);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool(_keyIsActive) ?? (_fallbackMemory[_keyIsActive] == true);
      if (isActive) {
        await prefs.setString(_keyStage, stage);
        if (extraData != null) {
          await prefs.setString(_keyExtraData, jsonEncode(extraData));
        }
      }
    } catch (e) {
      debugPrint('[Workflow] updateStage prefs error: $e');
    }
  }

  /// Get the active batch from SharedPreferences or Backend
  static Future<Map<String, dynamic>?> getActiveBatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool(_keyIsActive) ?? false;
      final localBatchId = prefs.getString(_keyBatchId);

      if (isActive && localBatchId != null && localBatchId.isNotEmpty) {
        return {
          'batchId': localBatchId,
          'fishType': prefs.getString(_keyFishType) ?? 'Fish',
          'rawWeight': prefs.getDouble(_keyRawWeight) ?? 1.0,
          'stage': prefs.getString(_keyStage) ?? 'waste_prediction',
          'isActive': true,
          'extraData': prefs.getString(_keyExtraData) != null
              ? jsonDecode(prefs.getString(_keyExtraData)!)
              : null,
        };
      }
    } catch (e) {
      debugPrint('[Workflow] Local getActiveBatch error: $e');
      if (_fallbackMemory[_keyIsActive] == true && _fallbackMemory[_keyBatchId] != null) {
        return {
          'batchId': _fallbackMemory[_keyBatchId],
          'fishType': _fallbackMemory[_keyFishType] ?? 'Fish',
          'rawWeight': _fallbackMemory[_keyRawWeight] ?? 1.0,
          'stage': _fallbackMemory[_keyStage] ?? 'waste_prediction',
          'isActive': true,
          'extraData': _fallbackMemory[_keyExtraData] != null
              ? jsonDecode(_fallbackMemory[_keyExtraData]!)
              : null,
        };
      }
    }

    // Fall back to checking backend active batch
    try {
      debugPrint('[Workflow] Checking backend active batch at $batchApiUrl/active...');
      final res = await http
          .get(Uri.parse("$batchApiUrl/active"))
          .timeout(const Duration(seconds: 4));

      debugPrint('[Workflow] Backend response: ${res.statusCode}: ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['active'] == true && data['batch'] != null) {
          final b = data['batch'];
          final batchId = b['batchId']?.toString() ?? '';
          final fishType = b['fishType']?.toString() ?? 'Fish';
          final rawWeight = (b['rawWeight'] as num?)?.toDouble() ?? 1.0;
          final stage = data['stage']?.toString() ?? 'waste_prediction';

          if (batchId.isNotEmpty) {
            await saveActiveBatch(
              batchId: batchId,
              fishType: fishType,
              rawWeight: rawWeight,
              stage: stage,
            );
            debugPrint('[Workflow] Restored active batch $batchId at stage $stage');
            return {
              'batchId': batchId,
              'fishType': fishType,
              'rawWeight': rawWeight,
              'stage': stage,
              'isActive': true,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('[Workflow] Error querying backend active batch: $e');
    }

    return null;
  }

  /// Clear active batch from persistent local storage
  static Future<void> clearActiveBatch() async {
    _fallbackMemory.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyBatchId);
      await prefs.remove(_keyFishType);
      await prefs.remove(_keyRawWeight);
      await prefs.remove(_keyStage);
      await prefs.setBool(_keyIsActive, false);
      await prefs.remove(_keyExtraData);
    } catch (e) {
      debugPrint('[Workflow] clearActiveBatch prefs error: $e');
    }
  }

  /// End batch process completely (Backend and local)
  static Future<bool> endBatchProcess(String batchId) async {
    // 1. Tell waste service to mark batch as completed/ended
    try {
      await http
          .post(
            Uri.parse("$batchApiUrl/$batchId/end-process"),
            headers: {"Content-Type": "application/json"},
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    // 2. Stop oven session on SmartDrying (cloud or local) - turns off heater and fan
    try {
      await http
          .post(
            Uri.parse("${AppConfig.iotBaseUrl}/api/iot/sessions/${Uri.encodeComponent(batchId)}/stop"),
            headers: {"Content-Type": "application/json"},
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}

    // 3. Universal stop to guarantee hardware actuators off
    try {
      await http
          .post(
            Uri.parse("${AppConfig.iotBaseUrl}/api/iot/stop"),
            headers: {"Content-Type": "application/json"},
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}

    // 4. Directly command actuators off on Raspberry Pi bridge (172.20.10.2:8081)
    try {
      await http
          .post(
            Uri.parse("http://172.20.10.2:8081/api/actuators"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"heater": false, "fan": false}),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}

    // 5. Stop active drying session on port 8003
    try {
      await http
          .post(
            Uri.parse("$dryingApiUrl/stop"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"reason": "end_process"}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    await clearActiveBatch();
    return true;
  }

  /// Human readable stage description
  static String getStageDisplayName(String stage) {
    switch (stage) {
      case 'waste_prediction':
        return 'Stage 1: Waste & Cutting Prediction';
      case 'salt_prediction':
        return 'Stage 2: Salt Calculation';
      case 'salting_monitoring':
        return 'Stage 2: Salting Process Active';
      case 'salting_completed':
        return 'Stage 2: Salting Finished';
      case 'drying_prediction':
        return 'Stage 3: Drying Time Prediction';
      case 'drying_dashboard':
        return 'Stage 3: Chamber Drying Active';
      case 'verification':
        return 'Stage 4: Verification Station';
      default:
        return 'Processing Stage';
    }
  }

  /// Navigate directly to the screen corresponding to the current running stage
  static void navigateToActiveStage(BuildContext context, Map<String, dynamic> activeBatch) {
    final stage = activeBatch['stage']?.toString() ?? 'waste_prediction';
    final batchId = activeBatch['batchId']?.toString() ?? '';
    final fishType = activeBatch['fishType']?.toString() ?? 'Fish';
    final rawWeight = (activeBatch['rawWeight'] as num?)?.toDouble() ?? 1.0;

    Widget targetScreen;

    switch (stage) {
      case 'waste_prediction':
        targetScreen = const WastePredictionScreen();
        break;
      case 'salt_prediction':
        targetScreen = SaltPredictionScreen(batchId: batchId);
        break;
      case 'salting_monitoring':
        targetScreen = SaltingMonitoringScreen(batchId: batchId);
        break;
      case 'salting_completed':
        targetScreen = SaltingCompletedScreen(
          batchId: batchId,
          fishType: fishType,
          currentWeight: rawWeight,
        );
        break;
      case 'drying_prediction':
        targetScreen = TimePredictionScreen(
          batchId: batchId,
          fishType: fishType,
          initialWeightKg: rawWeight,
          saltedCompleted: true,
        );
        break;
      case 'drying_dashboard':
        targetScreen = const DryingDashboardScreen();
        break;
      case 'verification':
        targetScreen = const MonitoringScreen();
        break;
      default:
        targetScreen = const WastePredictionScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  /// Show End Process confirmation dialog
  static Future<bool> showEndProcessDialog(BuildContext context, String batchId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.stop_circle_outlined, color: Colors.red.shade700, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              "End Batch Process",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to end process for Batch $batchId?",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              "Ending this process will mark the current batch as completed, terminate any active drying operations, and allow you to start a new batch.",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check, size: 18, color: Colors.white),
            label: const Text("End Process", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await endBatchProcess(batchId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text("Batch $batchId process ended successfully. You can now start a new batch."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      }
      return true;
    }
    return false;
  }
}
