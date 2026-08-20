import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
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

  Widget infoRow(String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value.isEmpty ? "N/A" : value,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(color: Colors.grey.shade100, height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 32),

              // Success checkmark illustration
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Company Added Successfully!",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "The new company has been saved and is available for notifications.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Company details card container
              Container(
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
                    const Padding(
                      padding: EdgeInsets.only(top: 18, left: 16, right: 16, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Company Information",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    infoRow("Company Name", companyName),
                    infoRow("Company Type", companyType),
                    infoRow("Contact Person", contactPerson),
                    infoRow("Phone Number", phone),
                    infoRow("Email Address", email),
                    infoRow("Address", address),
                    infoRow("Services", services),
                    infoRow("Notes", notes.isEmpty ? "-" : notes),
                    infoRow("Status", active ? "Active" : "Inactive", showDivider: false),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home_rounded, color: Colors.white),
                  label: const Text(
                    "Go to Dashboard",
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

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                  label: const Text(
                    "Add Another Company",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCompanyScreen(),
                      ),
                    );
                  },
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