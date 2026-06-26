import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/colors.dart';

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

  @override
  void dispose() {
    weightController.dispose();
    notesController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
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
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu),
                  ),
                  const Column(
                    children: [Icon(Icons.set_meal, size: 40)],
                  ),
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
              
              // Correctly structured widget placements
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
                      onPressed: () {},
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
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Create Batch",
                        style: TextStyle(
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
      keyboardType: TextInputType.number,
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