import 'package:flutter/material.dart';
import '../../models/processing_report_model.dart';
import '../../services/Batch/processing_report_service.dart';
import '../../widgets/Batch/colors.dart';

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

  InputDecoration _inputDecoration(String label, IconData icon, {String? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
              // Header navigation row
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
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  Image.asset('assets/images/logo.png', height: 70),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                "Edit Batch",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Form Container Card
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
                        decoration: _inputDecoration("Raw Weight", Icons.scale_outlined, suffix: "kg"),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Raw weight is required";
                          }
                          if (double.tryParse(value) == null) {
                            return "Enter a valid number";
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
                              await ProcessingReportService.updateBatch(
                                batchId: widget.batch.batchId,
                                fishType: fishController.text.trim(),
                                rawWeight: double.parse(weightController.text.trim()),
                                status: selectedStatus,
                              );

                              final updatedReport = ProcessingReportModel(
                                batchId: widget.batch.batchId,
                                fishType: fishController.text.trim(),
                                date: widget.batch.date,
                                rawWeight: double.parse(weightController.text.trim()),
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
