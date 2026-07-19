import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int currentIndex = 0;
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// App Bar
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

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),

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

                children: const [
                  Text(
                    "Categories",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  Text("See all", style: TextStyle(color: Colors.blue)),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 95,

                child: ListView(
                  scrollDirection: Axis.horizontal,

                  children: [
                    category("All", "assets/images/all.png"),

                    category("Karawala", "assets/images/karawala.jpg"),

                    category("Hurulla", "assets/images/hurulla.webdp"),

                    category("Thalapath", "assets/images/thalapath.jpg"),

                    category("Kelawalla", "assets/images/kelawalla.jpg"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: const [
                  Text(
                    "Popular Products",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  Text("See all", style: TextStyle(color: Colors.blue)),
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
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },

        selectedItemColor: Colors.blue,

        unselectedItemColor: Colors.black54,

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
    return Card(
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
    );
  }
}
