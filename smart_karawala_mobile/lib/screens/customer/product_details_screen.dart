import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;
  bool isReadMore = false;

  final Map<String, Map<String, dynamic>> _fishMetadata = {
    "salaya": {
      "fullName": "Salaya (Sardinella)",
      "subtitle": "Popular small dried sardinella fish",
      "price": "Rs. 1,400 / kg",
      "numericPrice": 1400.0,
      "image": "assets/images/salaya.jpg",
      "rating": "4.6",
      "reviews": "128 reviews",
      "sold": "240+ sold",
      "batchId": "SAL-2026-0101",
      "catchLocation": "Negombo, Sri Lanka",
      "processingDate": "07 May 2026",
      "expiryDate": "07 Nov 2026",
      "moisture": "16% (Optimal)",
      "grade": "A Grade",
      "confidence": "94%",
      "dryingMethod": "Sun Drying",
      "about": "High quality Salaya (Sardinella) dried using hygienic traditional sun-drying method. Rich in protein, omega-3 fatty acids, and essential minerals. Ideal for spicy sambols, traditional curries, or crispy deep frying.",
      "sellerName": "Negombo Dry Fish Processors",
      "sellerRating": "4.8",
      "sellerReviews": "236 reviews",
      "sellerPositive": "98% Positive",
    },
    "hurulla": {
      "fullName": "Hurulla (Trench Sardine)",
      "subtitle": "Great taste, premium dried herring",
      "price": "Rs. 1,600 / kg",
      "numericPrice": 1600.0,
      "image": "assets/images/hurulla.webp",
      "rating": "4.7",
      "reviews": "156 reviews",
      "sold": "310+ sold",
      "batchId": "HUR-2026-0102",
      "catchLocation": "Chilaw, Sri Lanka",
      "processingDate": "10 May 2026",
      "expiryDate": "10 Nov 2026",
      "moisture": "17% (Optimal)",
      "grade": "A Grade",
      "confidence": "93%",
      "dryingMethod": "Sun Drying",
      "about": "Premium grade Hurulla fish processed with natural rock salt curing. Offers a rich, authentic coastal flavor with a firm texture after cooking.",
      "sellerName": "Chilaw Marine Foods",
      "sellerRating": "4.9",
      "sellerReviews": "410 reviews",
      "sellerPositive": "99% Positive",
    },
    "kumbalawa": {
      "fullName": "Kumbalawa (Indian Mackerel)",
      "subtitle": "Traditional salted dried mackerel",
      "price": "Rs. 1,500 / kg",
      "numericPrice": 1500.0,
      "image": "assets/images/kumbalawa.jpg",
      "rating": "4.5",
      "reviews": "98 reviews",
      "sold": "190+ sold",
      "batchId": "KUM-2026-0103",
      "catchLocation": "Jaffna, Sri Lanka",
      "processingDate": "12 May 2026",
      "expiryDate": "12 Nov 2026",
      "moisture": "18% (Optimal)",
      "grade": "A Grade",
      "confidence": "91%",
      "dryingMethod": "Sun Drying",
      "about": "Authentic Kumbalawa mackerel salted and dried naturally under open sun. Packed with protein and distinct traditional sea flavors.",
      "sellerName": "Jaffna Heritage Processors",
      "sellerRating": "4.7",
      "sellerReviews": "189 reviews",
      "sellerPositive": "97% Positive",
    },
    "thora": {
      "fullName": "Thora (King Fish)",
      "subtitle": "High quality king fish slabs",
      "price": "Rs. 2,400 / kg",
      "numericPrice": 2400.0,
      "image": "assets/images/thora.png",
      "rating": "4.8",
      "reviews": "210 reviews",
      "sold": "450+ sold",
      "batchId": "THR-2026-0104",
      "catchLocation": "Trincomalee, Sri Lanka",
      "processingDate": "14 May 2026",
      "expiryDate": "14 Nov 2026",
      "moisture": "15% (Optimal)",
      "grade": "A Grade",
      "confidence": "96%",
      "dryingMethod": "Solar Dryer",
      "about": "Premium King Fish (Thora) thick cut slabs. Processed in state-of-the-art solar drying facilities ensuring low moisture, clean taste, and extended shelf life.",
      "sellerName": "Trinco Prime Fisheries",
      "sellerRating": "4.9",
      "sellerReviews": "530 reviews",
      "sellerPositive": "99% Positive",
    },
    "kelawalla": {
      "fullName": "Kelawalla (Yellowfin Tuna)",
      "subtitle": "Tuna style rich flavor",
      "price": "Rs. 2,000 / kg",
      "numericPrice": 2000.0,
      "image": "assets/images/kelawalla.webp",
      "rating": "4.7",
      "reviews": "175 reviews",
      "sold": "320+ sold",
      "batchId": "KEL-2026-0105",
      "catchLocation": "Mirissa, Sri Lanka",
      "processingDate": "15 May 2026",
      "expiryDate": "15 Nov 2026",
      "moisture": "17% (Optimal)",
      "grade": "A Grade",
      "confidence": "95%",
      "dryingMethod": "Sun Drying",
      "about": "Selected Yellowfin Tuna (Kelawalla) dry fish cuts. High density protein food, cured in controlled hygienic conditions for gourmet home cooking.",
      "sellerName": "Mirissa Ocean Delights",
      "sellerRating": "4.8",
      "sellerReviews": "310 reviews",
      "sellerPositive": "98% Positive",
    },
    "balaya": {
      "fullName": "Balaya (Tuna)",
      "subtitle": "Premium quality dried tuna",
      "price": "Rs. 1,950 / kg",
      "numericPrice": 1950.0,
      "image": "assets/images/balaya.jpg",
      "rating": "4.6",
      "reviews": "128 reviews",
      "sold": "180+ sold",
      "batchId": "TUN-2026-0143",
      "catchLocation": "Negombo, Sri Lanka",
      "processingDate": "07 May 2026",
      "expiryDate": "07 Nov 2026",
      "moisture": "18% (Optimal)",
      "grade": "A Grade",
      "confidence": "92%",
      "dryingMethod": "Sun Drying",
      "about": "High quality balaya (tuna) dried using hygienic traditional sun-drying method. Rich in protein and perfect for daily meals.",
      "sellerName": "Negombo Dry Fish Processors",
      "sellerRating": "4.8",
      "sellerReviews": "236 reviews",
      "sellerPositive": "98% Positive",
    },
    "linna": {
      "fullName": "Linna (Hardtail Scad)",
      "subtitle": "Salted & dried to perfection",
      "price": "Rs. 1,700 / kg",
      "numericPrice": 1700.0,
      "image": "assets/images/linna.jpg",
      "rating": "4.5",
      "reviews": "84 reviews",
      "sold": "160+ sold",
      "batchId": "LIN-2026-0107",
      "catchLocation": "Kalpitiya, Sri Lanka",
      "processingDate": "18 May 2026",
      "expiryDate": "18 Nov 2026",
      "moisture": "16% (Optimal)",
      "grade": "A Grade",
      "confidence": "90%",
      "dryingMethod": "Sun Drying",
      "about": "Fresh Linna scad cured in sea salt and sun-dried along the coastal breeze of Kalpitiya. Rich in flavor with a delicious crispy skin when fried.",
      "sellerName": "Kalpitiya Salt & Seafood",
      "sellerRating": "4.7",
      "sellerReviews": "145 reviews",
      "sellerPositive": "96% Positive",
    },
    "thalapath": {
      "fullName": "Thalapath (Sailfish)",
      "subtitle": "Premium quality sailfish",
      "price": "Rs. 2,200 / kg",
      "numericPrice": 2200.0,
      "image": "assets/images/thalapath.jpg",
      "rating": "4.8",
      "reviews": "192 reviews",
      "sold": "380+ sold",
      "batchId": "THL-2026-0108",
      "catchLocation": "Beruwala, Sri Lanka",
      "processingDate": "20 May 2026",
      "expiryDate": "20 Nov 2026",
      "moisture": "15% (Optimal)",
      "grade": "A Grade",
      "confidence": "96%",
      "dryingMethod": "Solar Dryer",
      "about": "Thick cuts of premium Sailfish (Thalapath). Naturally cured and dried with minimal salt for an authentic, rich savory meal.",
      "sellerName": "Beruwala Marine Exporters",
      "sellerRating": "4.9",
      "sellerReviews": "420 reviews",
      "sellerPositive": "99% Positive",
    },
    "paraw": {
      "fullName": "Paraw (Trevally)",
      "subtitle": "Trevally dry fish portions",
      "price": "Rs. 1,900 / kg",
      "numericPrice": 1900.0,
      "image": "assets/images/paraw.jpg",
      "rating": "4.6",
      "reviews": "112 reviews",
      "sold": "220+ sold",
      "batchId": "PAR-2026-0109",
      "catchLocation": "Galle, Sri Lanka",
      "processingDate": "22 May 2026",
      "expiryDate": "22 Nov 2026",
      "moisture": "17% (Optimal)",
      "grade": "A Grade",
      "confidence": "93%",
      "dryingMethod": "Sun Drying",
      "about": "Quality Paraw (Trevally) dried fish portions. Carefully dried to maintain optimal texture, aroma, and traditional taste.",
      "sellerName": "Galle Sea Products",
      "sellerRating": "4.8",
      "sellerReviews": "210 reviews",
      "sellerPositive": "97% Positive",
    },
    "mora": {
      "fullName": "Mora (Shark)",
      "subtitle": "Shark dry fish, thick cuts",
      "price": "Rs. 2,300 / kg",
      "numericPrice": 2300.0,
      "image": "assets/images/mora.jpg",
      "rating": "4.7",
      "reviews": "145 reviews",
      "sold": "290+ sold",
      "batchId": "MOR-2026-0110",
      "catchLocation": "Tangalle, Sri Lanka",
      "processingDate": "25 May 2026",
      "expiryDate": "25 Nov 2026",
      "moisture": "14% (Optimal)",
      "grade": "A Grade",
      "confidence": "94%",
      "dryingMethod": "Sun Drying",
      "about": "Boneless thick cut Mora (Shark) dried fish. Known for its solid meat texture and rich savory taste, ideal for devilled dry fish curries.",
      "sellerName": "Tangalle Coast Fisheries",
      "sellerRating": "4.8",
      "sellerReviews": "280 reviews",
      "sellerPositive": "98% Positive",
    },
  };

  Map<String, dynamic> _getFishDetails() {
    final String rawName = (widget.product["name"] ?? "Balaya").toString().toLowerCase();
    for (var key in _fishMetadata.keys) {
      if (rawName.contains(key)) {
        final Map<String, dynamic> meta = Map.from(_fishMetadata[key]!);
        // Override image or price if passed explicitly
        if (widget.product["image"] != null) {
          meta["image"] = widget.product["image"];
        }
        if (widget.product["price"] != null) {
          meta["price"] = widget.product["price"];
          String cleaned = (widget.product["price"] as String)
              .replaceAll("Rs.", "")
              .replaceAll("/ kg", "")
              .replaceAll("/kg", "")
              .replaceAll(",", "")
              .trim();
          meta["numericPrice"] = double.tryParse(cleaned) ?? meta["numericPrice"];
        }
        return meta;
      }
    }
    return _fishMetadata["balaya"]!;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final details = _getFishDetails();
    final int cartCount = cartProvider.cartCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1E293B)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyCartScreen()),
                  );
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D61D7),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      "$cartCount",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E293B)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Product link copied to clipboard!")),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery / Image Card Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      details["image"] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(Icons.set_meal, size: 80, color: AppColors.hint),
                          ),
                        );
                      },
                    ),
                  ),
                  // Top-Left Grade Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium, color: Color(0xFF1D61D7), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            details["grade"] as String,
                            style: const TextStyle(
                              color: Color(0xFF1D61D7),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom-Right Image Counter Badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "1 / 6",
                        style: TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == 0 ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == 0 ? const Color(0xFF1D61D7) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Title, Subtitle, Price & Stepper Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details["fullName"] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details["subtitle"] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details["price"] as String,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "${details["rating"]} ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                "(${details["reviews"]})",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  "|",
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                              ),
                              Text(
                                details["sold"] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Stepper Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Icon(Icons.remove, size: 16, color: Color(0xFF334155)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                "$quantity kg",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Icon(Icons.add, size: 16, color: Color(0xFF334155)),
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
            const SizedBox(height: 18),

            // Trust Badges Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTrustBadge(
                      Icons.check_circle_outline,
                      "AI Quality Checked",
                      "Automatically graded",
                    ),
                    Container(width: 1, height: 28, color: const Color(0xFFBBF7D0)),
                    _buildTrustBadge(
                      Icons.eco_outlined,
                      "Low Waste",
                      "Eco-friendly process",
                    ),
                    Container(width: 1, height: 28, color: const Color(0xFFBBF7D0)),
                    _buildTrustBadge(
                      Icons.verified_user_outlined,
                      "Safe Drying",
                      "Controlled & monitored",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Product Information Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
                        Expanded(
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.pin_outlined, "Batch ID", details["batchId"] as String),
                              const SizedBox(height: 10),
                              _buildInfoRow(Icons.location_on_outlined, "Catch Location", details["catchLocation"] as String),
                              const SizedBox(height: 10),
                              _buildInfoRow(Icons.event_outlined, "Processing Date", details["processingDate"] as String),
                              const SizedBox(height: 10),
                              _buildInfoRow(Icons.event_busy_outlined, "Expiry Date", details["expiryDate"] as String),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right Column
                        Expanded(
                          child: Column(
                            children: [
                              _buildInfoRowRight("Moisture Level", details["moisture"] as String, isGreen: true),
                              const SizedBox(height: 10),
                              _buildInfoRowRight("AI Grade (Model)", details["grade"] as String),
                              const SizedBox(height: 10),
                              _buildInfoRowRight("Confidence Score", details["confidence"] as String),
                              const SizedBox(height: 10),
                              _buildInfoRowRight("Drying Method", details["dryingMethod"] as String, isGreen: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // About this Product Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "About this Product",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      details["about"] as String,
                      maxLines: isReadMore ? null : 3,
                      overflow: isReadMore ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isReadMore = !isReadMore;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isReadMore ? "Read less" : "Read more",
                            style: const TextStyle(
                              color: Color(0xFF1D61D7),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Icon(
                            isReadMore ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: const Color(0xFF1D61D7),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seller Information Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Seller Information",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Icon(
                            Icons.storefront_outlined,
                            color: Color(0xFF1D61D7),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      details["sellerName"] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Color(0xFF1D61D7), size: 16),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    "${details["sellerRating"]} ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    "(${details["sellerReviews"]})  |  ${details["sellerPositive"]}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Opening ${details["sellerName"]} profile...")),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1D61D7),
                            side: const BorderSide(color: Color(0xFF1D61D7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          child: const Text(
                            "View Shop",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Total Price Display
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rs. ${((details["numericPrice"] as double) * quantity).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Add to Cart Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final productToAdd = {
                      "name": details["fullName"],
                      "price": details["price"],
                      "image": details["image"],
                      "rating": details["rating"],
                    };
                    Provider.of<CartProvider>(context, listen: false).addToCart(productToAdd, quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${details["fullName"]} ($quantity kg) added to cart!"),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text(
                    "Add to Cart",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D61D7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Buy Now Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final productToAdd = {
                      "name": details["fullName"],
                      "price": details["price"],
                      "image": details["image"],
                      "rating": details["rating"],
                    };
                    Provider.of<CartProvider>(context, listen: false).addToCart(productToAdd, quantity);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text(
                    "Buy Now",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF16A34A), size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Color(0xFF15803D),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9.5,
            color: Color(0xFF166534),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowRight(String label, String value, {bool isGreen = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isGreen ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
