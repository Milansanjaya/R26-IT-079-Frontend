import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';

typedef CartScreen = MyCartScreen;

class MyCartScreen extends StatelessWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD), // Light clean background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Cart",
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.text),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.text),
                onPressed: () {},
              ),
              if (cartProvider.cartCount > 0)
                Positioned(
                  right: 4,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      "${cartProvider.cartCount}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Banner: All items are quality checked and safe
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), // Light green background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "All items are quality checked and safe",
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Cart Items List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          "Your cart is empty",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.set_meal, color: AppColors.hint),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details and controls
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.text,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          cartProvider.removeFromCart(item.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${item.grade}   1kg",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.hint,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.price,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      // Quantity selector
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade200),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                cartProvider.updateQuantity(item.id, item.quantity - 1);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Text("-", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(
                                                "${item.quantity}",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                cartProvider.updateQuantity(item.id, item.quantity + 1);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Text("+", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Cost breakdown and Checkout Button
          if (items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal (${cartProvider.cartCount} items)",
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      Text(
                        "Rs. ${cartProvider.subtotal.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Delivery Fee",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      Text(
                        "Rs. ${cartProvider.deliveryFee.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Rs. ${cartProvider.total.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Proceed to Checkout",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
