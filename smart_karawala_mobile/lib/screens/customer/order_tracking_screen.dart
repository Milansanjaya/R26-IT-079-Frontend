import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderItem order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  String formatDate(DateTime dt) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Tracking status check to determine line colors and checkmark highlights
    final String status = order.status; // "Pending", "Processing", "Shipped", "Delivered"

    final bool isPendingActive = true; // Always active if order is placed
    final bool isProcessingActive = status == "Processing" || status == "Shipped" || status == "Delivered";
    final bool isShippedActive = status == "Shipped" || status == "Delivered";
    final bool isDeliveredActive = status == "Delivered";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Order Tracking",
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: AppColors.text),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order ID & Placed Date Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Order ID",
                        style: TextStyle(color: AppColors.hint, fontSize: 13),
                      ),
                      Text(
                        order.orderId,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Order Placed",
                        style: TextStyle(color: AppColors.hint, fontSize: 13),
                      ),
                      Text(
                        "${formatDate(order.orderDate)}, 10:30 AM",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Track Your Order Timeline
            const Text(
              "Track Your Order",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildTimelineItem(
                    title: "Pending",
                    subtitle: "We have received your order",
                    time: "${formatDate(order.orderDate)}, 10:30 AM",
                    isActive: isPendingActive,
                    isFirst: true,
                    color: Colors.green,
                  ),
                  _buildTimelineItem(
                    title: "Processing",
                    subtitle: "Your order is being prepared",
                    time: "${formatDate(order.orderDate)}, 02:15 PM",
                    isActive: isProcessingActive,
                    color: Colors.blue,
                  ),
                  _buildTimelineItem(
                    title: "Shipped",
                    subtitle: "Your order is on the way",
                    time: "Expected: ${formatDate(order.orderDate.add(const Duration(days: 1)))}",
                    isActive: isShippedActive,
                    color: Colors.blueGrey,
                  ),
                  _buildTimelineItem(
                    title: "Delivered",
                    subtitle: "Your order will be delivered",
                    time: "Expected: ${formatDate(order.orderDate.add(const Duration(days: 2)))}",
                    isActive: isDeliveredActive,
                    isLast: true,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. AI Batch Quality Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Batch ID",
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 14),
                      ),
                      Text(
                        order.batchId,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildBatchRow("Quality Grade (AI)", order.qualityGrade, const Color(0xFF2EAD4B)),
                  const SizedBox(height: 12),
                  _buildBatchRow("Drying Status", order.dryingStatus, const Color(0xFF2EAD4B), isIcon: true),
                  const SizedBox(height: 12),
                  _buildBatchRow("Moisture Level", order.moistureLevel, const Color(0xFF2EAD4B)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Close / Done button at bottom
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                "Back to Home",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isActive,
    bool isFirst = false,
    bool isLast = false,
    required Color color,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dot and Line Column
          Column(
            children: [
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isActive
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isActive ? color.withOpacity(0.5) : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isActive ? AppColors.text : AppColors.hint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isActive ? Colors.black87 : AppColors.hint,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.hint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchRow(String label, String value, Color highlightColor, {bool isIcon = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.hint,
            fontSize: 13,
          ),
        ),
        Row(
          children: [
            if (isIcon)
              Icon(Icons.check_circle, size: 16, color: highlightColor),
            if (isIcon)
              const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: highlightColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
