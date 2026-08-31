import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import 'customer_home.dart';
import 'order_tracking_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final OrderItem order;

  const PaymentSuccessScreen({
    super.key,
    required this.order,
  });

  String formatDate(DateTime dt) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final day = dt.day;
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? "PM" : "AM";
    return "$day $month $year, $hour:$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Confetti / Tick Illustration
              Stack(
                alignment: Alignment.center,
                children: [
                  // Confetti decoration (represented with custom container shapes or icon)
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    height: 90,
                    width: 90,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Payment Successful!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your order has been placed successfully.",
                style: TextStyle(
                  color: AppColors.hint,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Detail Table
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildRow("Order ID", order.orderId),
                    const Divider(height: 24),
                    _buildRow("Order Date", formatDate(order.orderDate)),
                    const Divider(height: 24),
                    _buildRow("Payment Method", order.paymentMethod),
                    const Divider(height: 24),
                    _buildRow(
                      "Total Amount",
                      "Rs. ${order.total.toStringAsFixed(2)}",
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Green Note Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_outlined, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.paymentMethod.contains("COD")
                            ? "You will pay when you receive your order.\nThank you for shopping with us!"
                            : "Thank you for your payment. Your order is processing!\nThank you for shopping with us!",
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(order: order),
                    ),
                  );
                },
                child: const Text(
                  "View Order Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerHome()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Continue Shopping",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {TextStyle? valueStyle}) {
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
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}
