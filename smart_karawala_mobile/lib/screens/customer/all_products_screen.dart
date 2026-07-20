import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import 'more_screen.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _sortBy = "Popular";

  final List<Map<String, dynamic>> _allProducts = [
    {
      "name": "Salaya",
      "price": "Rs. 1,400 / kg",
      "rating": "4.6",
      "image": "assets/images/salaya.jpg",
    },
    {
      "name": "Hurulla",
      "price": "Rs. 1,600 / kg",
      "rating": "4.7",
      "image": "assets/images/hurulla.webp",
    },
    {
      "name": "Kumbalawa",
      "price": "Rs. 1,500 / kg",
      "rating": "4.5",
      "image": "assets/images/kumbalawa.jpg",
    },
    {
      "name": "Thora",
      "price": "Rs. 2,400 / kg",
      "rating": "4.8",
      "image": "assets/images/thora.png",
    },
    {
      "name": "Kelawalla",
      "price": "Rs. 2,000 / kg",
      "rating": "4.7",
      "image": "assets/images/kelawalla.webp",
    },
    {
      "name": "Balaya",
      "price": "Rs. 1,800 / kg",
      "rating": "4.6",
      "image": "assets/images/balaya.jpg",
    },
    {
      "name": "Linna",
      "price": "Rs. 1,700 / kg",
      "rating": "4.5",
      "image": "assets/images/linna.jpg",
    },
    {
      "name": "Thalapath",
      "price": "Rs. 2,200 / kg",
      "rating": "4.8",
      "image": "assets/images/thalapath.jpg",
    },
    {
      "name": "Paraw",
      "price": "Rs. 1,900 / kg",
      "rating": "4.6",
      "image": "assets/images/paraw.jpg",
    },
    {
      "name": "Mora",
      "price": "Rs. 2,300 / kg",
      "rating": "4.7",
      "image": "assets/images/mora.jpg",
    },
  ];

  double parsePrice(String priceStr) {
    String cleaned = priceStr
        .replaceAll("Rs.", "")
        .replaceAll("/ kg", "")
        .replaceAll("/kg", "")
        .replaceAll(",", "")
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // Filter and sort products
    List<Map<String, dynamic>> filteredProducts = List.from(_allProducts);
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => p["name"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_sortBy == "Popular" || _sortBy == "Rating") {
      filteredProducts.sort((a, b) {
        final double rA = double.tryParse(a["rating"].toString()) ?? 0.0;
        final double rB = double.tryParse(b["rating"].toString()) ?? 0.0;
        return rB.compareTo(rA);
      });
    } else if (_sortBy == "Price: Low to High") {
      filteredProducts.sort((a, b) {
        return parsePrice(a["price"]).compareTo(parsePrice(b["price"]));
      });
    } else if (_sortBy == "Price: High to Low") {
      filteredProducts.sort((a, b) {
        return parsePrice(b["price"]).compareTo(parsePrice(a["price"]));
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const MoreScreen(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Products",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // Notification icon with badge 3
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Colors.black),
              ),
              Positioned(
                right: 8,
                top: 8,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Cart icon with badge count
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyCartScreen()),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
              ),
              if (cartProvider.cartCount > 0)
                Positioned(
                  right: 4,
                  top: 8,
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
          // Drawer menu
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: const Icon(Icons.search, color: AppColors.hint),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.text),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Product count and Sorting dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${filteredProducts.length} Products",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _sortBy == "Rating" ? "Popular" : _sortBy,
                      underline: const SizedBox.shrink(),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.text),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortBy = newValue;
                          });
                        }
                      },
                      items: <String>['Popular', 'Price: Low to High', 'Price: High to Low']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text("Sort by: $value"),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Grid
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              "No products found for \"$_searchQuery\"",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredProducts.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.76,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(context, product, cartProvider);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product, CartProvider cartProvider) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade100, width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      product["image"],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.set_meal, color: AppColors.hint, size: 36),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Product Name
              Text(
                product["name"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Product Price
              Text(
                product["price"],
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),

              // Rating and Cart Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Star Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        product["rating"],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  // Add to Cart Small Button
                  GestureDetector(
                    onTap: () {
                      cartProvider.addToCart(product, 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product["name"]} added to cart!"),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
