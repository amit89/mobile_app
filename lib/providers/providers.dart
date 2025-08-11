import 'package:flutter/material.dart';

export 'cart_provider.dart';

// Auth Provider
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isAdmin = false;
  String? _userId;
  String? _userName;
  String? _mobile;
  String? _email;

  bool get isAdmin => _isAdmin;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get mobile => _mobile;
  String? get email => _email;

  // Store user credentials (in a real app, this would be in a secure storage)
  final Map<String, UserCredentials> _users = {
    '7814260451': UserCredentials(
      userId: 'admin_user',
      mobile: '7814260451',
      email: 'admin@greengrab.com',
      password: '123456',
      isAdmin: true,
    ),
  };

  void register({
    required String mobile,
    required String email,
    required String password,
  }) {
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _users[email] = UserCredentials(
      userId: userId,
      mobile: mobile,
      email: email,
      password: password,
    );
    _users[mobile] = UserCredentials(
      userId: userId,
      mobile: mobile,
      email: email,
      password: password,
    );
  }

  bool login({
    required String emailOrMobile,
    required String password,
  }) {
    final userCredentials = _users[emailOrMobile];
    if (userCredentials != null && userCredentials.password == password) {
      _isAuthenticated = true;
      _isAdmin = userCredentials.isAdmin;
      _userId = userCredentials.userId;
      _mobile = userCredentials.mobile;
      _email = userCredentials.email;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _mobile = null;
    _email = null;
    notifyListeners();
  }
}

// Cart Provider
class CartProvider with ChangeNotifier {
  final List<CartItemData> _items = [];

  List<CartItemData> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  void addToCart(ProductData product) {
    final existingIndex = _items.indexWhere((item) => item.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItemData(
        id: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      if (quantity > 0) {
        _items[existingIndex].quantity = quantity;
      } else {
        _items.removeAt(existingIndex);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// Product Provider
class ProductProvider with ChangeNotifier {
  List<ProductData> _products = [];
  List<CategoryData> _categories = [];
  bool _isLoading = false;

  List<ProductData> get products => _products;
  List<CategoryData> get categories => _categories;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setProducts(List<ProductData> products) {
    _products = products;
    notifyListeners();
  }

  void setCategories(List<CategoryData> categories) {
    _categories = categories;
    notifyListeners();
  }

  void addProduct(String categoryId, ProductData product) {
    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex >= 0) {
      _categories[categoryIndex].products.add(product);
      notifyListeners();
    }
  }

  void deleteProduct(String categoryId, String productId) {
    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex >= 0) {
      _categories[categoryIndex].products.removeWhere((p) => p.id == productId);
      notifyListeners();
    }
  }
}

// Data classes for providers
class CartItemData {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItemData({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class ProductData {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;

  ProductData({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
  });
}

class CategoryData {
  final String id;
  final String name;
  final List<ProductData> products;

  CategoryData({
    required this.id,
    required this.name,
    required this.products,
  });
}

class UserCredentials {
  final String userId;
  final bool isAdmin;
  final String mobile;
  final String email;
  final String password;

  UserCredentials({
    required this.userId,
    required this.mobile,
    required this.email,
    required this.password,
    this.isAdmin = false,
  });
}