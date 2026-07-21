import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  String? selectedGrade;
  
  final nameController = TextEditingController();
  final batchIdController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    batchIdController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Product",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Section
              const Text(
                "Product Image",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              // Dotted / Bordered Upload Card
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1.5,
                    style: BorderStyle.solid, // solid fallback for clean dotted aesthetic
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.image_outlined, color: Colors.blue, size: 28),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Upload Image",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "PNG, JPG up to 5MB",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Product Name Field
              const Text(
                "Product Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration("Enter product name"),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 20),

              // Batch ID Field
              const Text(
                "Batch ID",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: batchIdController,
                decoration: _inputDecoration("Enter batch ID"),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 20),

              // Category Field
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                isExpanded: true,
                decoration: _inputDecoration("Select category"),
                items: const [
                  DropdownMenuItem(value: "Dry Fish", child: Text("Dry Fish")),
                  DropdownMenuItem(value: "Salted Fish", child: Text("Salted Fish")),
                ],
                onChanged: (val) => setState(() => selectedCategory = val),
                validator: (value) => value == null ? "Required" : null,
              ),

              const SizedBox(height: 20),

              // Quality Grade Field
              const Text(
                "Quality Grade",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                isExpanded: true,
                decoration: _inputDecoration("Select grade"),
                items: const [
                  DropdownMenuItem(value: "Grade A", child: Text("Grade A")),
                  DropdownMenuItem(value: "Grade B", child: Text("Grade B")),
                  DropdownMenuItem(value: "Grade C", child: Text("Grade C")),
                ],
                onChanged: (val) => setState(() => selectedGrade = val),
                validator: (value) => value == null ? "Required" : null,
              ),

              const SizedBox(height: 20),

              // Price & Quantity Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price (per kg)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _inputDecoration("\$ 0.00"),
                          validator: (value) => value == null || value.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quantity (kg)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("0"),
                          validator: (value) => value == null || value.isEmpty ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description Field
              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: _inputDecoration("Enter description"),
              ),

              const SizedBox(height: 32),

              // Add Product Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Product Added Successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Add Product",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
