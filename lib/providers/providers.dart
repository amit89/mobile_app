import 'package:flutter/material.dart';

export 'cart_provider.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/auth_service.dart';
import '../config/config.dart';

// Auth Provider
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isAdmin = false;
  String? _userId;
  String? _userName;
  String? _mobile;
  String? _email;
  final AuthService _authService = AuthService();

  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _isAuthenticated || _authService.isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get mobile => _mobile;
  String? get email => _email;

  // Store user credentials (imported from firebase_config.dart)
  final Map<String, UserCredentials> _users = {
    FirebaseConfig.adminMobile: UserCredentials(
      userId: FirebaseConfig.adminUserId,
      mobile: FirebaseConfig.adminMobile,
      email: FirebaseConfig.adminEmail,
      password: FirebaseConfig.adminPassword,
      isAdmin: true,
    ),
  };

  // Initialize with current Firebase user if available
  AuthProvider() {
    // Initialize with current user if available
    if (_authService.currentUser != null) {
      _updateUserFromFirebase(_authService.currentUser!);
    }
    
    // Listen for auth state changes
    _authService.userStream.listen((firebase_auth.User? user) {
      if (user != null) {
        print('AuthProvider: Firebase user signed in: ${user.uid}');
        _updateUserFromFirebase(user);
        notifyListeners();
      } else {
        print('AuthProvider: Firebase user signed out');
        // Optionally reset user state if they sign out
      }
    });
  }

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

  // Legacy login method (non-Firebase)
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

  // Login with Firebase user
  void loginWithFirebaseUser(firebase_auth.User user) {
    try {
      _updateUserFromFirebase(user);
      notifyListeners();
    } catch (e) {
      print('Error in loginWithFirebaseUser: $e');
      // Handle error or rethrow as needed
    }
  }

  // Update user data from Firebase user
  void _updateUserFromFirebase(firebase_auth.User user) {
    try {
      _isAuthenticated = true;
      _userId = user.uid;
      _mobile = user.phoneNumber;
      _email = user.email;
      _userName = user.displayName;
      
      // Check if user is admin using admin config
      _isAdmin = _mobile == FirebaseConfig.adminMobile || _email == FirebaseConfig.adminEmail;
      
      print('Firebase user processed successfully: UID=${_userId}, Phone=${_mobile}');
    } catch (e) {
      print('Error processing Firebase user: $e');
      throw e; // Re-throw to handle in the calling method
    }
  }

  // Logout from both Firebase and local state
  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print('Error signing out from Firebase: $e');
    } finally {
      _isAuthenticated = false;
      _userId = null;
      _userName = null;
      _mobile = null;
      _email = null;
      notifyListeners();
    }
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