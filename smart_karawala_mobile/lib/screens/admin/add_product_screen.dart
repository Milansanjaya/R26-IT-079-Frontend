import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import 'manage_orders_screen.dart';
import 'sales_dashboard_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentIndex = 1;

  String? selectedCategory;
  String? selectedGrade;
  String? selectedImageAsset;

  final nameController = TextEditingController();
  final batchIdController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<Map<String, String>> sampleImages = [
    {"name": "Dry Mora (Shark)", "asset": "assets/images/mora.jpg"},
    {"name": "Balaya (Tuna)", "asset": "assets/images/balaya.jpg"},
    {"name": "Salmon Dry", "asset": "assets/images/all.jpg"},
    {"name": "Kelawalla (Skipjack)", "asset": "assets/images/kelawalla.webp"},
    {"name": "Dry Katta", "asset": "assets/images/karawala.jpg"},
  ];

  @override
  void dispose() {
    nameController.dispose();
    batchIdController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Product Image",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sampleImages.length,
                  itemBuilder: (context, i) {
                    final img = sampleImages[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImageAsset = img["asset"];
                          if (nameController.text.isEmpty) {
                            nameController.text = img["name"]!;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                img["asset"]!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              img["name"]!.split(" ")[0],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
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
              GestureDetector(
                onTap: _showImagePickerModal,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: selectedImageAsset != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                selectedImageAsset!,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        )
                      : Column(
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
                validator: (value) => value == null || value.trim().isEmpty ? "Product name is required" : null,
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
                validator: (value) => value == null || value.trim().isEmpty ? "Batch ID is required" : null,
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
                  DropdownMenuItem(value: "Smoked Fish", child: Text("Smoked Fish")),
                ],
                onChanged: (val) => setState(() => selectedCategory = val),
                validator: (value) => value == null ? "Category is required" : null,
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
                  DropdownMenuItem(value: "Grade A", child: Text("Grade A (Export Quality)")),
                  DropdownMenuItem(value: "Grade B", child: Text("Grade B (Premium)")),
                  DropdownMenuItem(value: "Grade C", child: Text("Grade C (Standard)")),
                ],
                onChanged: (val) => setState(() => selectedGrade = val),
                validator: (value) => value == null ? "Grade is required" : null,
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
                          validator: (value) => value == null || value.trim().isEmpty ? "Price is required" : null,
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
                          validator: (value) => value == null || value.trim().isEmpty ? "Quantity is required" : null,
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
                        SnackBar(
                          content: Text("Product '${nameController.text}' Added Successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Clear form after success
                      nameController.clear();
                      batchIdController.clear();
                      priceController.clear();
                      quantityController.clear();
                      descriptionController.clear();
                      setState(() {
                        selectedCategory = null;
                        selectedGrade = null;
                        selectedImageAsset = null;
                      });
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SalesDashboardScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: "Add Product",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: "Manage Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded),
            label: "Sales Analytics",
          ),
        ],
      ),
    );
  }
}
