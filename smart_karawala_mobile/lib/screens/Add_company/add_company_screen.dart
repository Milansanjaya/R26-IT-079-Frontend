import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import 'company_added_success_screen.dart';
import 'package:flutter/services.dart';

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({super.key});

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final companyName = TextEditingController();
  final contactPerson = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? companyType;
  String? serviceType;
  bool active = true;

  @override
  void dispose() {
    companyName.dispose();
    contactPerson.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    notes.dispose();
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

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: label == "Phone Number"
            ? TextInputType.number
            : label == "Email Address"
                ? TextInputType.emailAddress
                : TextInputType.text,
        inputFormatters: label == "Phone Number"
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : (label == "Company Name" || label == "Contact Person")
                ? [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z ]'),
                    ),
                  ]
                : null,
        decoration: _inputDecoration(label, icon),
        validator: (value) {
          final text = value?.trim() ?? "";

          if (label == "Notes (Optional)") {
            return null;
          }

          if (text.isEmpty) {
            return "$label is required";
          }

          if (label == "Company Name") {
            if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(text)) {
              return "Only letters are allowed";
            }
          }

          if (label == "Contact Person") {
            if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(text)) {
              return "Only letters are allowed";
            }
          }

          if (label == "Phone Number") {
            if (!RegExp(r'^[0-9]{10}$').hasMatch(text)) {
              return "Enter a valid phone number";
            }
          }

          if (label == "Email Address") {
            if (!RegExp(
              r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
            ).hasMatch(text)) {
              return "Invalid email";
            }
          }

          if (label == "Address") {
            if (text.length < 5) {
              return "Enter a valid address";
            }
          }

          return null;
        },
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _inputDecoration(label, icon),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select $label";
          }
          return null;
        },
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: onChanged,
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
                  Image.asset('assets/images/logo.png', height: 48),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                "Add New Company",
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
                      buildTextField(
                        controller: companyName,
                        label: "Company Name",
                        icon: Icons.business_outlined,
                      ),

                      buildDropdown(
                        label: "Company Type",
                        icon: Icons.apartment_outlined,
                        value: companyType,
                        items: const [
                          "Recycling Company",
                          "Fish Meal Company",
                          "Compost Company",
                        ],
                        onChanged: (v) {
                          setState(() {
                            companyType = v;
                          });
                        },
                      ),

                      buildTextField(
                        controller: contactPerson,
                        label: "Contact Person",
                        icon: Icons.person_outline_rounded,
                      ),

                      buildTextField(
                        controller: phone,
                        label: "Phone Number",
                        icon: Icons.phone_outlined,
                      ),

                      buildTextField(
                        controller: email,
                        label: "Email Address",
                        icon: Icons.email_outlined,
                      ),

                      buildTextField(
                        controller: address,
                        label: "Address",
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),

                      buildDropdown(
                        label: "Services Accepted",
                        icon: Icons.sell_outlined,
                        value: serviceType,
                        items: const ["Fish Waste", "Fish Meal", "Compost"],
                        onChanged: (v) {
                          setState(() {
                            serviceType = v;
                          });
                        },
                      ),

                      buildTextField(
                        controller: notes,
                        label: "Notes (Optional)",
                        icon: Icons.chat_bubble_outline_rounded,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 8),

                      // Status Switch
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SwitchListTile(
                          value: active,
                          activeColor: AppColors.primary,
                          title: const Text(
                            "Active Status",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: const Text(
                            "Company will be available for notifications.",
                            style: TextStyle(fontSize: 12),
                          ),
                          onChanged: (v) {
                            setState(() {
                              active = v;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CompanyAddedSuccessScreen(
                                  companyName: companyName.text,
                                  companyType: companyType ?? "",
                                  contactPerson: contactPerson.text,
                                  phone: phone.text,
                                  email: email.text,
                                  address: address.text,
                                  services: serviceType ?? "",
                                  notes: notes.text,
                                  active: active,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded, color: Colors.white),
                          label: const Text(
                            "Save Company",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
