import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import 'batch_created_success_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../admin/admin_home_screen.dart';

class AddNewBatchScreen extends StatefulWidget {
  const AddNewBatchScreen({super.key});

  @override
  State<AddNewBatchScreen> createState() => _AddNewBatchScreenState();
}

class _AddNewBatchScreenState extends State<AddNewBatchScreen> {
  final weightController = TextEditingController();
  final notesController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? fish;
  String? location;
  String? weightError;
  bool isLoading = false; // Added to handle progress status

  @override
  void dispose() {
    weightController.dispose();
    notesController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  // Moved inside the State class so it can access fields dynamically
  Future<void> saveBatch() async {
    if (fish == null || location == null || weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    final double? parsedWeight = double.tryParse(weightController.text);
    if (parsedWeight == null || parsedWeight <= 0 || parsedWeight > 4.5) {
      const msg = "Raw Fish Weight must be between 0.001 kg and 4.5 kg";
      setState(() {
        weightError = msg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(msg)),
      );
      return;
    } else {
      setState(() {
        weightError = null;
      });
    }

    setState(() {
      isLoading = true;
    });

    // Auto-generate a batchId since there is no input field for it in the UI
    final generatedBatchId =
        "B${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    final url = Uri.parse("http://localhost:8001/api/batches");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "batchId": generatedBatchId,
          "fishType": fish,
          "rawWeight": parsedWeight,
          "date": dateController.text,
          "time": timeController.text,
          "location": location,
          "notes": notesController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BatchCreatedSuccessScreen(
              batchId: generatedBatchId,
              fishType: fish!,
              rawWeight: "${weightController.text} kg",
              date: dateController.text,
              time: timeController.text,
              location: location!,
              notes: notesController.text,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save batch (${response.statusCode}): ${response.body}"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon, String? suffix, String? errorText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      suffixIcon: suffixIcon,
      suffixText: suffix,
      suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
      errorText: errorText,
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7)),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            children: [
              // Header navigation row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHomeScreen(),
                        ),
                      );
                    },
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHomeScreen(),
                        ),
                      );
                    },
                    child: Image.asset('assets/images/logo.png', height: 70),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Add New Batch",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assignment_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start a new batch",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Provide accurate details for better prediction and tracking.",
                            style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Form Container Card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Batch Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    buildDropdown(Icons.set_meal_outlined, "Fish Type", fish, [
                      "Salaya",
                      "Hurulla",
                      "Kumbalawa",
                      "Thora",
                      "Kelawalla",
                      "Balaya",
                      "Linna",
                      "Thalapath",
                      "Paraw",
                      "Mora",
                    ]),
                    const SizedBox(height: 16),

                    buildWeight(),
                    const SizedBox(height: 16),

                    buildDropdown(Icons.location_on_outlined, "Location", location, [
                      "Mathara",
                      "Chillaw",
                      "Deundara",
                      "Negombo",
                      "Jaffna",
                      "Trincomalee",
                    ]),
                    const SizedBox(height: 16),

                    buildDate(),
                    const SizedBox(height: 16),

                    buildTime(),
                    const SizedBox(height: 16),

                    buildNotes(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cancel & Save Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminHomeScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(0, 56),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveBatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button,
                        disabledBackgroundColor: AppColors.button.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(0, 56),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Create Batch",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quality Tip Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Soft green background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade100, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.green.shade700, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Why accurate details matter?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Accurate batch information helps us provide better predictions, reduce waste, and ensure top quality.",
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _validateWeight(String val) {
    if (val.trim().isEmpty) {
      setState(() {
        weightError = null;
      });
      return;
    }
    final double? parsed = double.tryParse(val);
    if (parsed == null || parsed <= 0 || parsed > 4.5) {
      setState(() {
        weightError = "Weight must be greater than 0 and up to 4.5 kg";
      });
    } else {
      setState(() {
        weightError = null;
      });
    }
  }

  Widget buildWeight() {
    return TextField(
      controller: weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}$')),
      ],
      onChanged: _validateWeight,
      decoration: _inputDecoration(
        "Raw Fish Weight",
        Icons.scale_outlined,
        suffix: "kg",
        errorText: weightError,
      ),
    );
  }

  Widget buildNotes() {
    return TextField(
      controller: notesController,
      maxLines: 4,
      decoration: _inputDecoration("Notes (Optional)", Icons.note_alt_outlined),
    );
  }

  Widget buildDate() {
    return TextField(
      controller: dateController,
      readOnly: true,
      onTap: pickDate,
      decoration: _inputDecoration("Date", Icons.calendar_today_outlined),
    );
  }

  Widget buildTime() {
    return TextField(
      controller: timeController,
      readOnly: true,
      onTap: pickTime,
      decoration: _inputDecoration("Time", Icons.access_time_outlined),
    );
  }

  Widget buildDropdown(
    IconData icon,
    String title,
    String? value,
    List<String> items,
  ) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(title, icon),
      value: value,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) {
        setState(() {
          if (title == "Fish Type") {
            fish = v;
          } else {
            location = v;
          }
        });
      },
    );
  }
}
