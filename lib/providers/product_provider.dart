import 'package:flutter/foundation.dart';
import '../models/product_models.dart';
import '../services/firebase_service.dart';
import '../services/category_service.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final CategoryService _categoryService = CategoryService();

  List<CategoryData> _categories = [];
  List<ProductData> _products = [];
  bool _isLoading = false;

  List<CategoryData> get categories => _categories;
  List<ProductData> get products => _products;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    setLoading(true);
    try {
      _categoryService.getCategories().listen((categories) {
        _categories = categories;
        notifyListeners();
      });
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> addProduct(ProductData product) async {
    try {
      await _firebaseService.addProduct(product);
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductData product) async {
    try {
      await _firebaseService.updateProduct(product);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firebaseService.deleteProduct(productId);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> addCategory(CategoryData category) async {
    try {
      await _categoryService.addCategory(category);
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryData category) async {
    try {
      await _categoryService.updateCategory(category);
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoryService.deleteCategory(categoryId);
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }
}
