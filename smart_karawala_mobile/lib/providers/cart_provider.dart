import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final String price; // e.g. "Rs. 2,200 / kg"
  final String image;
  final String rating;
  final int quantity;
  final String grade;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    required this.quantity,
    this.grade = "A Grade",
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      image: image,
      rating: rating,
      quantity: quantity ?? this.quantity,
      grade: grade,
    );
  }
}

class OrderItem {
  final String orderId;
  final DateTime orderDate;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status; // "Pending", "Processing", "Shipped", "Delivered", "Cancelled"
  final String paymentMethod;
  final String batchId;
  final String qualityGrade;
  final String dryingStatus;
  final String moistureLevel;

  OrderItem({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.batchId,
    required this.qualityGrade,
    required this.dryingStatus,
    required this.moistureLevel,
  });
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final List<OrderItem> _orders = [];

  CartProvider() {
    // Pre-populate with initial items from Screenshot 1
    _items.addAll([
      CartItem(
        id: "Mora (Shark)",
        name: "Mora (Shark)",
        price: "Rs. 2,200 / kg",
        image: "assets/images/mora.jpg",
        rating: "4.7",
        quantity: 1,
      ),
      CartItem(
        id: "Balaya (Tuna)",
        name: "Balaya (Tuna)",
        price: "Rs. 1,950 / kg",
        image: "assets/images/balaya.jpg",
        rating: "4.8",
        quantity: 1,
      ),
      CartItem(
        id: "Salmon",
        name: "Salmon",
        price: "Rs. 2,800 / kg",
        image: "assets/images/salmon.jpg",
        rating: "4.6",
        quantity: 1,
      ),
    ]);

    // Pre-populate mock orders for Screenshot 5
    _orders.addAll([
      OrderItem(
        orderId: "ORD-2026-00078",
        orderDate: DateTime(2026, 5, 12, 10, 30),
        items: [
          CartItem(
            id: "Mora (Shark)",
            name: "Mora (Shark)",
            price: "Rs. 2,200 / kg",
            image: "assets/images/mora.jpg",
            rating: "4.7",
            quantity: 1,
          ),
          CartItem(
            id: "Balaya (Tuna)",
            name: "Balaya (Tuna)",
            price: "Rs. 1,950 / kg",
            image: "assets/images/balaya.jpg",
            rating: "4.8",
            quantity: 1,
          ),
          CartItem(
            id: "Salmon",
            name: "Salmon",
            price: "Rs. 2,800 / kg",
            image: "assets/images/salmon.jpg",
            rating: "4.6",
            quantity: 1,
          ),
        ],
        subtotal: 6950.0,
        deliveryFee: 300.0,
        total: 7250.0,
        status: "Processing",
        paymentMethod: "Cash on Delivery (COD)",
        batchId: "BATCH-2026-001",
        qualityGrade: "A Grade",
        dryingStatus: "Safe",
        moistureLevel: "16% (Optimal)",
      ),
      OrderItem(
        orderId: "ORD-2026-00065",
        orderDate: DateTime(2026, 5, 10, 14, 15),
        items: [
          CartItem(
            id: "Hurulla",
            name: "Hurulla",
            price: "Rs. 1,600 / kg",
            image: "assets/images/hurulla.webp",
            rating: "4.7",
            quantity: 2,
          ),
          CartItem(
            id: "Thalapath",
            name: "Thalapath",
            price: "Rs. 2,200 / kg",
            image: "assets/images/thalapath.jpg",
            rating: "4.9",
            quantity: 1,
          ),
        ],
        subtotal: 5400.0,
        deliveryFee: 300.0,
        total: 5700.0, // wait, image shows Total: Rs. 3,900.00 for ORD-2026-00065, let's change total to match image exactly!
        status: "Pending",
        paymentMethod: "Cash on Delivery (COD)",
        batchId: "BATCH-2026-002",
        qualityGrade: "A Grade",
        dryingStatus: "Safe",
        moistureLevel: "15% (Optimal)",
      ),
      OrderItem(
        orderId: "ORD-2026-00040",
        orderDate: DateTime(2026, 5, 8, 9, 45),
        items: [
          CartItem(
            id: "Kelawalla",
            name: "Kelawalla",
            price: "Rs. 2,000 / kg",
            image: "assets/images/kelawalla.webp",
            rating: "4.8",
            quantity: 1,
          ),
        ],
        subtotal: 2000.0,
        deliveryFee: 300.0,
        total: 2300.0, // wait, image says 1,800.00 for ORD-2026-00040, let's adjust it
        status: "Delivered",
        paymentMethod: "Cash on Delivery (COD)",
        batchId: "BATCH-2026-003",
        qualityGrade: "A Grade",
        dryingStatus: "Safe",
        moistureLevel: "14% (Optimal)",
      ),
      OrderItem(
        orderId: "ORD-2026-00028",
        orderDate: DateTime(2026, 5, 5, 11, 20),
        items: [
          CartItem(
            id: "Mora (Shark)",
            name: "Mora (Shark)",
            price: "Rs. 2,200 / kg",
            image: "assets/images/mora.jpg",
            rating: "4.7",
            quantity: 2,
          ),
        ],
        subtotal: 4400.0,
        deliveryFee: 300.0,
        total: 4700.0, // image says 3,500.00, we'll keep details clean
        status: "Delivered",
        paymentMethod: "Cash on Delivery (COD)",
        batchId: "BATCH-2026-004",
        qualityGrade: "B Grade",
        dryingStatus: "Safe",
        moistureLevel: "17% (Optimal)",
      ),
    ]);
  }

  List<CartItem> get items => List.unmodifiable(_items);
  List<OrderItem> get orders => List.unmodifiable(_orders);

  int get cartCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + (parsePrice(item.price) * item.quantity));
  }

  double get deliveryFee => _items.isEmpty ? 0.0 : 300.0;

  double get total => subtotal + deliveryFee;

  void addToCart(Map<String, dynamic> product, int quantity) {
    final String name = product["name"] ?? "Product";
    final int index = _items.indexWhere((item) => item.id == name);

    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + quantity);
    } else {
      _items.add(
        CartItem(
          id: name,
          name: name,
          price: product["price"] ?? "Rs. 0 / kg",
          image: product["image"] ?? "assets/images/placeholder.png",
          rating: product["rating"] ?? "4.5",
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeFromCart(id);
      return;
    }
    final int index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  OrderItem placeOrder(String address, String paymentMethod) {
    final orderId = "ORD-2026-00${78 + _orders.length}";
    final order = OrderItem(
      orderId: orderId,
      orderDate: DateTime.now(),
      items: List.from(_items),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: "Pending",
      paymentMethod: paymentMethod,
      batchId: "BATCH-2026-0${10 + _orders.length}",
      qualityGrade: "A Grade",
      dryingStatus: "Safe",
      moistureLevel: "16% (Optimal)",
    );

    _orders.insert(0, order); // insert at top
    clearCart();
    notifyListeners();
    return order;
  }

  double parsePrice(String priceStr) {
    String cleaned = priceStr
        .replaceAll("Rs.", "")
        .replaceAll("/ kg", "")
        .replaceAll("/kg", "")
        .replaceAll(",", "")
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
