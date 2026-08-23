import 'package:flutter/material.dart';
import '../../models/processing_report_model.dart';
import '../../services/Batch/processing_report_service.dart';
import '../../widgets/Batch/colors.dart';
import '../admin/admin_home_screen.dart';

class EditBatchScreen extends StatefulWidget {
  final ProcessingReportModel batch;

  const EditBatchScreen({super.key, required this.batch});

  @override
  State<EditBatchScreen> createState() => _EditBatchScreenState();
}

class _EditBatchScreenState extends State<EditBatchScreen> {
  late TextEditingController fishController;
  late TextEditingController weightController;
  late String selectedStatus;
  String weightUnit = "kg";
  final _formKey = GlobalKey<FormState>();

  final List<String> statusOptions = [
    'In Progress',
    'Completed',
    'Not Started',
    'Pending',
    'Salting',
    'Drying',
  ];

  @override
  void initState() {
    super.initState();
    fishController = TextEditingController(text: widget.batch.fishType);
    weightController = TextEditingController(
      text: widget.batch.rawWeight.toString(),
    );
    selectedStatus = widget.batch.status;
    if (!statusOptions.contains(selectedStatus)) {
      statusOptions.insert(0, selectedStatus);
    }
  }

  @override
  void dispose() {
    fishController.dispose();
    weightController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon, String? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      suffixIcon: suffixIcon,
      suffixText: suffix,
      suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitOption("kg"),
          _unitOption("g"),
        ],
      ),
    );
  }

  Widget _unitOption(String unit) {
    final isSelected = weightUnit == unit;
    return GestureDetector(
      onTap: () {
        if (weightUnit != unit) {
          final val = double.tryParse(weightController.text);
          if (val != null && val > 0) {
            if (unit == "g" && weightUnit == "kg") {
              final inG = (val * 1000).round();
              weightController.text = inG.toString();
            } else if (unit == "kg" && weightUnit == "g") {
              final inKg = val / 1000.0;
              weightController.text = inKg
                  .toStringAsFixed(3)
                  .replaceAll(RegExp(r'0+$'), '')
                  .replaceAll(RegExp(r'\.$'), '');
            }
          }
          setState(() {
            weightUnit = unit;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
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
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
                    ),
                  ),
                  Image.asset('assets/images/logo.png', height: 70),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Edit Batch",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Container(
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
                      TextFormField(
                        controller: fishController,
                        decoration: _inputDecoration("Fish Type", Icons.set_meal_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Fish type is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration(
                          "Raw Weight",
                          Icons.scale_outlined,
                          suffixIcon: _buildUnitToggle(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Raw weight is required";
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return "Enter a valid number greater than 0";
                          }
                          final inKg = weightUnit == "g" ? parsed / 1000.0 : parsed;
                          if (inKg > 4.5) {
                            return weightUnit == "g"
                                ? "Weight must be up to 4500 g (4.5 kg)"
                                : "Weight must be up to 4.5 kg";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: _inputDecoration("Status", Icons.verified_user_outlined),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedStatus = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Status is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            try {
                              final double parsedVal = double.parse(weightController.text.trim());
                              final double parsedRawKg = weightUnit == "g" ? parsedVal / 1000.0 : parsedVal;

                              await ProcessingReportService.updateBatch(
                                batchId: widget.batch.batchId,
                                fishType: fishController.text.trim(),
                                rawWeight: parsedRawKg,
                                status: selectedStatus,
                              );

                              final updatedReport = ProcessingReportModel(
                                batchId: widget.batch.batchId,
                                fishType: fishController.text.trim(),
                                date: widget.batch.date,
                                rawWeight: parsedRawKg,
                                predictedWaste: widget.batch.predictedWaste,
                                wastePercentage: widget.batch.wastePercentage,
                                status: selectedStatus,
                              );

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Batch Updated Successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pop(context, updatedReport);
                            } catch (e) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check_rounded, color: Colors.white),
                          label: const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.button,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              const Center(
                child: Text(
                  "Powered by Smart Karawala",
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
