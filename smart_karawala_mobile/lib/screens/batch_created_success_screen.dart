import 'package:flutter/material.dart';
import 'admin_home_screen.dart';
import 'add_new_batch_screen.dart';

class BatchCreatedSuccessScreen extends StatelessWidget {
  final String batchId;
  final String fishType;
  final String rawWeight;
  final String date;
  final String time;
  final String location;
  final String notes;

  const BatchCreatedSuccessScreen({
    super.key,
    required this.batchId,
    required this.fishType,
    required this.rawWeight,
    required this.date,
    required this.time,
    required this.location,
    required this.notes,
  });

  Widget item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [

              const SizedBox(height: 20),

              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Batch Created Successfully!",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Your new batch has been created and saved.",
              ),

              const SizedBox(height: 25),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      item("Batch ID", batchId),
                      item("Fish Type", fishType),
                      item("Raw Weight", "$rawWeight kg"),
                      item("Date", date),
                      item("Time", time),
                      item("Location", location),
                      item("Notes", notes),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Create Another Batch"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddNewBatchScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text("Go to Dashboard"),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminHomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}