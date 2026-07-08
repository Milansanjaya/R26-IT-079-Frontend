import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF7FF),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              //--------------------------------
              // Header
              //--------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Column(
                    children: const [
                      Icon(Icons.set_meal, color: Colors.blue, size: 45),

                      Text(
                        "Smart",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text("කරවල"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Add New Company",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff174C7B),
                ),
              ),

              const SizedBox(height: 25),

              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Column(
                    children: [
                      buildTextField(
                        controller: companyName,
                        label: "Company Name",
                        icon: Icons.business,
                      ),

                      buildDropdown(
                        label: "Company Type",
                        icon: Icons.apartment,
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
                        icon: Icons.person_outline,
                      ),

                      buildTextField(
                        controller: phone,
                        label: "Phone Number",
                        icon: Icons.phone,
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
                        icon: Icons.chat_bubble_outline,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 10),

                      SwitchListTile(
                        value: active,
                        title: const Text("Active Status"),
                        subtitle: const Text(
                          "Company will be available for notifications.",
                        ),
                        onChanged: (v) {
                          setState(() {
                            active = v;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

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

                          icon: const Icon(Icons.add),

                          label: const Text("Save Company"),
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

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
          : (label == "Company Name" ||
                  label == "Contact Person")
              ? [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z ]'),
                  ),
                ]
              : null,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

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
              child: Text(e),
            ),
          )
          .toList(),

      onChanged: onChanged,
    ),
  );
}
  }


