import 'package:flutter/material.dart';
import '../Add_company/add_company_screen.dart';

class WasteNotificationScreen extends StatefulWidget {
  final double predictedWaste;
  const WasteNotificationScreen({super.key, required this.predictedWaste});

  @override
  State<WasteNotificationScreen> createState() =>
      _WasteNotificationScreenState();
}

class _WasteNotificationScreenState extends State<WasteNotificationScreen> {
  final TextEditingController collectionDateController =
      TextEditingController();

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
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    collectionDateController.text = "${now.day}/${now.month}/${now.year}";
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
              //------------------------------------------------
              // Header
              //------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Container(
                    width: 45,
                    height: 45,

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

              const SizedBox(height: 30),

              const Text(
                "Waste Notification",

                style: TextStyle(
                  fontSize: 34,

                  fontWeight: FontWeight.bold,

                  color: Color(0xff174C7B),
                ),
              ),

              const SizedBox(height: 30),

              //------------------------------------------------
              // Company Selection Card
              //------------------------------------------------
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: const [
                        Icon(Icons.group, color: Colors.blue),

                        SizedBox(width: 10),

                        Text(
                          "1. Select Company",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,

                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Choose one or more companies to notify.",

                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    //------------------------------------------------
                    // Company List
                    //------------------------------------------------
                    ListView.builder(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: companies.length,

                      itemBuilder: (context, index) {
                        final company = companies[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),

                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Row(
                            children: [
                              Checkbox(
                                value: company["selected"],

                                onChanged: (value) {
                                  setState(() {
                                    company["selected"] = value!;
                                  });
                                },
                              ),

                              CircleAvatar(
                                backgroundColor: Colors.blue.shade50,

                                child: Icon(
                                  company["icon"],
                                  color: Colors.blue,
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
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(company["phone"]),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),

                                decoration: BoxDecoration(
                                  color: company["selected"]
                                      ? Colors.green.shade100
                                      : Colors.grey.shade200,

                                  borderRadius: BorderRadius.circular(8),
                                ),

                                child: Text(
                                  company["selected"] ? "Selected" : "Select",

                                  style: TextStyle(
                                    fontSize: 12,

                                    color: company["selected"]
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //------------------------------------------------
              // 2. Waste Details
              //------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.scale, color: Colors.blue),

                        SizedBox(width: 10),

                        Text(
                          "2. Waste Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        //------------------------------------------------
                        // Estimated Waste
                        //------------------------------------------------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Estimated Waste Quantity",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                initialValue:
                                    "${widget.predictedWaste.toStringAsFixed(1)}",

                                decoration: InputDecoration(
                                  suffixText: "kg",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 15),

                        //------------------------------------------------
                        // Collection Date
                        //------------------------------------------------
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Preferred Collection Date",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller: collectionDateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.calendar_month),
                                  suffixIcon: const Icon(Icons.arrow_drop_down),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
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

              //------------------------------------------------
              // 3. Additional Message
              //------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.chat_bubble_outline, color: Colors.blue),

                        SizedBox(width: 10),

                        Text(
                          "3. Additional Message (Optional)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      maxLines: 5,
                      maxLength: 200,

                      decoration: InputDecoration(
                        hintText: "Add any additional information...",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //------------------------------------------------
              // Send Notification Button
              //------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Notification sent successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // TODO:
                    // Call your backend API here.
                    //
                    // Example:
                    // await BatchService.sendNotification(batchId);
                  },

                  icon: const Icon(Icons.send),

                  label: const Text(
                    "Send Notification",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0A3E91),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //------------------------------------------------
              // Information Card
              //------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF6FF),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Companies will receive your waste details and estimated quantity for better planning and collection.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              

              //------------------------------------------------
              // Create New Company
              //------------------------------------------------
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCompanyScreen(),
                    ),
                  );
                },

                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xffEEF5FF),
                        child: Icon(Icons.add, color: Colors.blue),
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "Create new recycling or\nfish meal processing companies",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              //------------------------------------------------
              // Footer
              //------------------------------------------------
              const Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
