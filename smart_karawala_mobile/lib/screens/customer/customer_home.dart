import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_karawala_mobile/screens/customer/more_screen.dart';
import 'package:smart_karawala_mobile/screens/customer/profile_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import 'categories_screen.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int currentIndex = 0;
  String selectedOrderTab = "All";
  final List<Map<String, dynamic>> products = [
    {
      "name": "Karawala",
      "price": "Rs. 1800 / kg",
      "rating": "4.8",
      "image": "assets/images/karawala.jpg",
    },
    {
      "name": "Hurulla",
      "price": "Rs. 1600 / kg",
      "rating": "4.7",
      "image": "assets/images/hurulla.webp",
    },
    {
      "name": "Thalapath",
      "price": "Rs. 2200 / kg",
      "rating": "4.9",
      "image": "assets/images/thalapath.jpg",
    },
    {
      "name": "Kelawalla",
      "price": "Rs. 2000 / kg",
      "rating": "4.8",
      "image": "assets/images/kelawalla.webp",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const MoreScreen(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Standard App Bar (Common header)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/images/logo.png", width: 80),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_none),
                          ),
                          Positioned(
                            right: 8,
                            top: 6,
                            child: Container(
                              height: 16,
                              width: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  "3",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyCartScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart_outlined),
                          ),
                          Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              if (cartProvider.cartCount == 0) return const SizedBox.shrink();
                              return Positioned(
                                right: 4,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
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
                              );
                            },
                          ),
                        ],
                      ),
                      Builder(
                        builder: (context) {
                          return IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),

              /// Dynamic Tab Content
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            ).then((val) {
              if (val != null && val is int) {
                setState(() {
                  currentIndex = val;
                });
              }
            });
            return;
          }

          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Orders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  /// Switch display widget depending on active tab
  Widget _buildTabContent() {
    switch (currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const CategoriesScreen();
      case 2:
        return _buildOrdersTab();
      default:
        return _buildHomeTab();
    }
  }

  /// 1. Home tab body
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Search
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search dry fish...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.tune),
              ),
            ],
          ),
          const SizedBox(height: 25),

          /// Banner
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                image: AssetImage("assets/images/banner.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Categories",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
                child: const Text("See all", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 95,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                category("All", "assets/images/all.jpg"),
                category("Karawala", "assets/images/karawala.jpg"),
                category("Hurulla", "assets/images/hurulla.webp"),
                category("Thalapath", "assets/images/thalapath.jpg"),
                category("Kelawalla", "assets/images/kelawalla.webp"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Popular Products",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(
                        product: const {
                          "name": "Mora (Shark)",
                          "price": "Rs. 2,200 / kg",
                          "image": "assets/images/mora.jpg",
                          "rating": "4.7",
                        },
                      ),
                    ),
                  );
                },
                child: const Text("See all", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .62,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (_, index) {
              return productCard(products[index]);
            },
          ),
        ],
      ),
    );
  }

  /// 2. Orders tab body (Mocked and Live orders)
  Widget _buildOrdersTab() {
    final cartProvider = Provider.of<CartProvider>(context);
    final orders = cartProvider.orders;

    // Filter orders by selected status tab
    final filteredOrders = orders.where((order) {
      if (selectedOrderTab == "All") return true;
      return order.status.toLowerCase() == selectedOrderTab.toLowerCase();
    }).toList();

    final orderTabs = ["All", "Pending", "Processing", "Delivered", "Cancelled"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Filter icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Orders",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: AppColors.text),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tabs Header
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: orderTabs.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final tab = orderTabs[index];
              final isSelected = selectedOrderTab == tab;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOrderTab = tab;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Orders List
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        "No $selectedOrderTab orders found.",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredOrders.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final String image = order.items.isNotEmpty
                        ? order.items.first.image
                        : "assets/images/placeholder.png";

                    // Format dates
                    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                    final dateStr = "${order.orderDate.day} ${months[order.orderDate.month - 1]} ${order.orderDate.year}";

                    // Status style
                    Color badgeColor;
                    Color textColor;
                    switch (order.status.toLowerCase()) {
                      case "pending":
                        badgeColor = Colors.orange.shade50;
                        textColor = Colors.orange.shade800;
                        break;
                      case "processing":
                        badgeColor = Colors.blue.shade50;
                        textColor = Colors.blue.shade800;
                        break;
                      case "delivered":
                        badgeColor = Colors.green.shade50;
                        textColor = Colors.green.shade800;
                        break;
                      case "cancelled":
                        badgeColor = Colors.red.shade50;
                        textColor = Colors.red.shade800;
                        break;
                      default:
                        badgeColor = Colors.grey.shade100;
                        textColor = Colors.black87;
                    }

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
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(order: order),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.set_meal, color: AppColors.hint),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order.orderId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: badgeColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          order.status,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      color: AppColors.hint,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${order.items.fold(0, (sum, i) => sum + i.quantity)} items",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        "Total: Rs. ${order.total.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: AppColors.hint),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget category(String title, String image) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget productCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Image.asset(
                  product["image"],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(product["price"]),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(product["rating"]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
