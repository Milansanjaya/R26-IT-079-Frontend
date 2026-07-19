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
          "rawWeight": double.tryParse(weightController.text) ?? 0.0,
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
              rawWeight: weightController.text,
              date: dateController.text,
              time: timeController.text,
              location: location!,
              notes: notesController.text,
            ),
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),

                  const Column(children: [Icon(Icons.set_meal, size: 40)]),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Add New Batch",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.assignment),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start a new batch",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Provide accurate details for better prediction and tracking.",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Batch Information",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              buildDropdown(Icons.set_meal, "Fish Type", fish, [
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

              const SizedBox(height: 15),
              buildWeight(),

              const SizedBox(height: 15),

              buildDropdown(Icons.location_on_outlined, "Location", location, [
                "Mathara",
                "Chillaw",
                "Deundara",
                "Negombo",
                "Jaffna",
                "Trincomalee",
              ]),

              const SizedBox(height: 15),
              buildDate(),

              const SizedBox(height: 15),
              buildTime(),

              const SizedBox(height: 15),
              buildNotes(),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(0, 55),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      // Attached the saveBatch execution block here
                      onPressed: isLoading ? null : saveBatch,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 255, 1, 1),
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(
                        isLoading ? "Saving..." : "Create Batch",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button,
                        minimumSize: const Size(0, 55),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xffEDFCEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Why accurate details matter?",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Accurate batch information helps us provide better predictions, reduce waste and ensure quality.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWeight() {
    return TextField(
      controller: weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
      ],
      decoration: const InputDecoration(
        labelText: "Raw Fish Weight",
        suffixText: "kg",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildNotes() {
    return TextField(
      controller: notesController,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: "Notes (Optional)",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildDate() {
    return TextField(
      controller: dateController,
      readOnly: true,
      onTap: pickDate,
      decoration: InputDecoration(
        labelText: "Date",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: pickDate,
        ),
      ),
    );
  }

  Widget buildTime() {
    return TextField(
      controller: timeController,
      readOnly: true,
      onTap: pickTime,
      decoration: InputDecoration(
        labelText: "Time",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: pickTime,
        ),
      ),
    );
  }

  Widget buildDropdown(
    IconData icon,
    String title,
    String? value,
    List<String> items,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: title,
        border: const OutlineInputBorder(),
      ),
      value: value,
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
