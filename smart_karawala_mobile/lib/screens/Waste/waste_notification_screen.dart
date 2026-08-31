import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import '../Add_company/add_company_screen.dart';
import '../admin/admin_home_screen.dart';
import '../Salt/salt_prediction_screen.dart';

class WasteNotificationScreen extends StatefulWidget {
  final double predictedWaste;
  final String? batchId;
  final double? wastePercentage;

  const WasteNotificationScreen({
    super.key,
    required this.predictedWaste,
    this.batchId,
    this.wastePercentage,
  });

  @override
  State<WasteNotificationScreen> createState() =>
      _WasteNotificationScreenState();
}

class _WasteNotificationScreenState extends State<WasteNotificationScreen> {
  bool isNotificationSent = false;

  final TextEditingController collectionDateController =
      TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final List<Map<String, dynamic>> companies = [
    {
      "name": "Ocean Recyclers (Pvt) Ltd",
      "phone": "+94 77 123 4567",
      "selected": true,
      "icon": Icons.public,
    },
    {
      "name": "Ceylon Fish Meal (Pvt) Ltd",
      "phone": "+94 71 987 6543",
      "selected": true,
      "icon": Icons.recycling,
    },
    {
      "name": "BlueWave Eco Solutions",
      "phone": "+94 70 555 8899",
      "selected": false,
      "icon": Icons.water,
    },
  ];

  Widget _buildNotificationStatusCard(double pct) {
    String statusText;
    String notificationLevel;
    Color cardBg;
    Color borderColor;
    Color textColor;
    String emoji;

    if (pct <= 10.0) {
      emoji = "🟢";
      statusText = "Low Waste";
      notificationLevel = "Normal";
      cardBg = const Color(0xFFE8F5E9);
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade900;
    } else if (pct <= 20.0) {
      emoji = "🟡";
      statusText = "Moderate Waste";
      notificationLevel = "Warning";
      cardBg = const Color(0xFFFFF8E1);
      borderColor = Colors.amber.shade400;
      textColor = Colors.amber.shade900;
    } else {
      emoji = "🔴";
      statusText = "High Waste";
      notificationLevel = "Alert";
      cardBg = const Color(0xFFFFEBEE);
      borderColor = Colors.red.shade300;
      textColor = Colors.red.shade900;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        notificationLevel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Waste Percentage: ${pct.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    collectionDateController.text = "${now.day}/${now.month}/${now.year}";
    
    double predKg = widget.predictedWaste > 100 ? widget.predictedWaste / 1000.0 : widget.predictedWaste;
    if (predKg <= 0) predKg = 21.75;
    quantityController.text = predKg.toStringAsFixed(1);
    messageController.text = "Please come waste collected";

    quantityController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    collectionDateController.dispose();
    messageController.dispose();
    quantityController.dispose();
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              const Text(
                "Waste Notification",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Waste Percentage Status Notification Card
              _buildNotificationStatusCard(
                widget.wastePercentage ?? (widget.predictedWaste > 0 && widget.predictedWaste <= 100 ? widget.predictedWaste : 15.0),
              ),

              // 1. Company Selection Card
              Container(
                width: double.infinity,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.group_outlined, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "1. Select Company",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Choose one or more companies to notify.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Company List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: companies.length,
                      itemBuilder: (context, index) {
                        final company = companies[index];
                        final bool isSelected = company["selected"];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF0F6FC) : Colors.white,
                            border: Border.all(
                              color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.grey.shade200,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                company["selected"] = !isSelected;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        company["selected"] = value!;
                                      });
                                    },
                                  ),
                                  CircleAvatar(
                                    backgroundColor: isSelected ? Colors.white : AppColors.background,
                                    child: Icon(
                                      company["icon"],
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          company["name"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.text,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          company["phone"],
                                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFE8F5E9)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isSelected ? "Selected" : "Select",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.green.shade800
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Waste Details Card
              Container(
                width: double.infinity,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.scale_outlined, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "2. Waste Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        // Estimated Waste
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Estimated Waste Quantity",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: quantityController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _inputDecoration("Quantity", Icons.delete_outline_rounded, suffix: "kg"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Collection Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Preferred Collection Date",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: collectionDateController,
                                readOnly: true,
                                decoration: _inputDecoration("Date", Icons.calendar_today_outlined),
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2035),
                                  );

                                  if (picked != null) {
                                    setState(() {
                                      collectionDateController.text =
                                          "${picked.day}/${picked.month}/${picked.year}";
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Additional Message Card
              Container(
                width: double.infinity,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "3. Additional Message (Optional)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: "Add any additional information...",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey.shade50,
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
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Send Notification Button or Threshold Notice
              Builder(
                builder: (context) {
                  final double? parsedVal = double.tryParse(quantityController.text);
                  final double qtyKg = (parsedVal != null && parsedVal > 100)
                      ? parsedVal / 1000.0
                      : (parsedVal ?? 0.0);
                  final bool isBelowThreshold = qtyKg < 1.0;

                  if (isBelowThreshold) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade300, width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Collection Threshold Notice",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Predicted waste is below the 1 kg collection threshold. No recycling notification is required.",
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isNotificationSent = true;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Notification sent successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: Icon(
                        isNotificationSent ? Icons.check_circle_rounded : Icons.send_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        isNotificationSent ? "Notification Sent" : "Send Notification",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNotificationSent ? Colors.green.shade700 : AppColors.button,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  );
                },
              ),

              if (isNotificationSent) ...[
                const SizedBox(height: 14),

                // Next Step: Salt Prediction Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SaltPredictionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.opacity_rounded, color: Colors.white),
                    label: const Text(
                      "Next Step: Salt Prediction",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Information Card banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // Soft blue tint
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade100, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.blue.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Companies will receive your waste details and estimated quantity for better planning and collection.",
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Create New Company Card Link
              Container(
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
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCompanyScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Create Recycling Company",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Add new recycling or fish meal processing companies",
                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.hint),
                        ],
                      ),
                    ),
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
