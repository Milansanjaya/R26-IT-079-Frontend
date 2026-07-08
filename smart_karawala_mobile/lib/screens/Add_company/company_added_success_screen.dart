import 'package:flutter/material.dart';
import '../admin/admin_home_screen.dart';
import 'add_company_screen.dart';

class CompanyAddedSuccessScreen extends StatelessWidget {
  final String companyName;
  final String companyType;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String services;
  final String notes;
  final bool active;

  const CompanyAddedSuccessScreen({
    super.key,
    required this.companyName,
    required this.companyType,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.services,
    required this.notes,
    required this.active,
  });

  Widget infoRow(
      IconData icon,
      Color color,
      String title,
      String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [

          Icon(icon, color: color, size: 20),

          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
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

              //-------------------------------------
              // Header
              //-------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  Column(
                    children: const [
                      Icon(
                        Icons.set_meal,
                        color: Colors.blue,
                        size: 45,
                      ),
                      Text(
                        "Smart",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("කරවල"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //-------------------------------------
              // Success Card
              //-------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Column(
                  children: [

                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Company Added Successfully!",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "The new company has been saved and is available for notifications.",
                      textAlign: TextAlign.center,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              //-------------------------------------
              // Company Information
              //-------------------------------------

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Column(
                  children: [

                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Company Information",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    infoRow(Icons.business,
                        Colors.blue,
                        "Company Name",
                        companyName),

                    infoRow(Icons.apartment,
                        Colors.indigo,
                        "Company Type",
                        companyType),

                    infoRow(Icons.person,
                        Colors.deepPurple,
                        "Contact Person",
                        contactPerson),

                    infoRow(Icons.phone,
                        Colors.green,
                        "Phone Number",
                        phone),

                    infoRow(Icons.email,
                        Colors.purple,
                        "Email Address",
                        email),

                    infoRow(Icons.location_on,
                        Colors.orange,
                        "Address",
                        address),

                    infoRow(Icons.recycling,
                        Colors.blue,
                        "Services",
                        services),

                    infoRow(Icons.note,
                        Colors.deepPurple,
                        "Notes",
                        notes.isEmpty
                            ? "-"
                            : notes),

                    infoRow(Icons.toggle_on,
                        Colors.green,
                        "Status",
                        active
                            ? "Active"
                            : "Inactive"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //-------------------------------------
              // Buttons
              //-------------------------------------

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text(
                      "Add Another Company"),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddCompanyScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text(
                    "Go to Dashboard",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff0A3E91),
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AdminHomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Powered by Smart Karawala",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}