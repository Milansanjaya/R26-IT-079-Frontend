import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'product_details_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _categories = [
  {
    "name": "Salaya",
    "desc": "Popular small dried fish",
    "image": "assets/images/salaya.jpg",
    "gradient": [Colors.blue, Colors.blueAccent],
  },
  {
    "name": "Hurulla",
    "desc": "Great taste, premium dried",
    "image": "assets/images/hurulla.webp",
    "gradient": [Colors.teal, Colors.tealAccent],
  },
  {
    "name": "Kumbalawa",
    "desc": "Traditional salted dried fish",
    "image": "assets/images/kumbalawa.jpg",
    "gradient": [Colors.orange, Colors.orangeAccent],
  },
  {
    "name": "Thora",
    "desc": "High quality king fish slabs",
    "image": "assets/images/thora.png",
    "gradient": [Colors.indigo, Colors.indigoAccent],
  },
  {
    "name": "Kelawalla",
    "desc": "Tuna style rich flavor",
    "image": "assets/images/kelawalla.webp",
    "gradient": [Colors.purple, Colors.purpleAccent],
  },
  {
    "name": "Balaya",
    "desc": "Local favorite dried tuna",
    "image": "assets/images/balaya.jpg",
    "gradient": [Colors.red, Colors.redAccent],
  },
  {
    "name": "Linna",
    "desc": "Salted & dried to perfection",
    "image": "assets/images/linna.jpg",
    "gradient": [Colors.amber, Colors.orange],
  },
  {
    "name": "Thalapath",
    "desc": "Premium quality sailfish",
    "image": "assets/images/thalapath.jpg",
    "gradient": [Colors.cyan, Colors.cyanAccent],
  },
  {
    "name": "Paraw",
    "desc": "Trevally dry fish portions",
    "image": "assets/images/paraw.jpg",
    "gradient": [Colors.deepOrange, Colors.orangeAccent],
  },
  {
    "name": "Mora",
    "desc": "Shark dry fish, thick cuts",
    "image": "assets/images/mora.jpg",
    "gradient": [Colors.blueGrey, Colors.grey],
  },
];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _categories
        .where((cat) => cat["name"]
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header title
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 10),
          child: Text(
            "Categories",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 20),
          child: Text(
            "Browse our premium range of dry fish",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.hint,
            ),
          ),
        ),

        /// Search Bar
        TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: "Search categories...",
            prefixIcon: const Icon(Icons.search, color: AppColors.hint),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.hint),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 25),

        /// Categories Grid
        Expanded(
          child: filteredCategories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 15),
                      Text(
                        "No categories found for \"$_searchQuery\"",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  itemCount: filteredCategories.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final cat = filteredCategories[index];
                    final List<Color> gradient = cat["gradient"] as List<Color>;
                    final Color primaryColor = gradient[0];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.10),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withOpacity(0.14),
                          width: 1.2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: {
                                    "name": cat["name"],
                                    "image": cat["image"],
                                  },
                                ),
                              ),
                            );
                          },
                          splashColor: primaryColor.withOpacity(0.1),
                          highlightColor: primaryColor.withOpacity(0.05),
                          child: Stack(
                            children: [
                              // Top-right subtle glow accent background bubble
                              Positioned(
                                top: -20,
                                right: -20,
                                child: Container(
                                  width: 85,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        primaryColor.withOpacity(0.18),
                                        primaryColor.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(height: 2),
                                    // Avatar Container with gradient border ring & dynamic shadow
                                    Container(
                                      width: 76,
                                      height: 76,
                                      padding: const EdgeInsets.all(3.5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: gradient,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.35),
                                            blurRadius: 12,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: ClipOval(
                                          child: Image.asset(
                                            cat["image"] as String,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: primaryColor.withOpacity(0.1),
                                                child: Icon(
                                                  Icons.set_meal,
                                                  color: primaryColor,
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          cat["name"] as String,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.text,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          cat["desc"] as String,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            height: 1.2,
                                            color: AppColors.hint.withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Professional bottom "Explore" button pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Explore",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 10,
                                            color: primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
