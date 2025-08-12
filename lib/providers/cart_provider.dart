
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import 'package:flutter/material.dart';
import 'product_provider.dart';
import '../models/product_models.dart' as product_models;

class ProductData {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;
  final String? categoryId;
  final int quantity;

  ProductData({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    this.categoryId,
    this.quantity = 0,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  // Reference to the ProductProvider
  ProductProvider? _productProvider;

  Map<String, CartItem> get items => {..._items};

  int get totalItems {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0, (sum, item) => sum + item.total);
  }
  
  // Set the product provider reference
  void setProductProvider(ProductProvider provider) {
    _productProvider = provider;
    print('CartProvider: ProductProvider reference set successfully');
  }

  Future<bool> addToCart(ProductData product) async {
    // Check if we have a product provider reference
    if (_productProvider == null) {
      print('CartProvider: ProductProvider is null - cannot add product to cart');
      return false;
    }
    
    // Find the product in the provider to get current quantity
    product_models.ProductData? currentProduct;
    for (var category in _productProvider!.categories) {
      try {
        final foundProduct = category.products.firstWhere(
          (p) => p.id == product.id,
        );
        currentProduct = foundProduct;
        print('CartProvider: Found product ${foundProduct.name} with quantity ${foundProduct.quantity}');
        break;
      } catch (e) {
        // Product not found in this category, continue to next
        print('CartProvider: Product not found in category ${category.name}');
      }
    }
    
    // If product not found or out of stock, return false
    if (currentProduct == null) {
      print('CartProvider: Product ${product.id} not found in any category');
      return false;
    }
    
    if (currentProduct.quantity <= 0) {
      print('CartProvider: Product ${currentProduct.name} is out of stock (quantity: ${currentProduct.quantity})');
      return false;
    }
    
    // Update cart
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          id: existingItem.id,
          name: existingItem.name,
          price: existingItem.price,
          image: existingItem.image,
          unit: existingItem.unit,
          categoryId: existingItem.categoryId,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          image: product.image,
          unit: product.unit,
          categoryId: product.categoryId,
        ),
      );
    }
    
    // Update product quantity in the database
    try {
      await _productProvider!.updateProductQuantity(product.id, currentProduct.quantity - 1);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating product quantity: $e');
      return false;
    }
  }

  Future<void> decrementQuantity(String productId) async {
    if (!_items.containsKey(productId)) {
      return;
    }

    // Find the product in the provider to restore quantity
    product_models.ProductData? currentProduct;
    if (_productProvider != null) {
      for (var category in _productProvider!.categories) {
        try {
          final foundProduct = category.products.firstWhere(
            (p) => p.id == productId,
          );
          currentProduct = foundProduct;
          break;
        } catch (e) {
          // Product not found in this category, continue to next
        }
      }
    }

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          name: existingItem.name,
          price: existingItem.price,
          image: existingItem.image,
          unit: existingItem.unit,
          categoryId: existingItem.categoryId,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    
    // Update product quantity in the database (increase by 1 since we're removing from cart)
    if (currentProduct != null && _productProvider != null) {
      try {
        await _productProvider!.updateProductQuantity(productId, currentProduct.quantity + 1);
      } catch (e) {
        print('Error updating product quantity: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    if (!_items.containsKey(productId)) {
      return;
    }
    
    // Get the quantity we need to return to inventory
    final quantityToReturn = _items[productId]!.quantity;
    
    // Find the product in the provider to restore quantity
    product_models.ProductData? currentProduct;
    if (_productProvider != null) {
      for (var category in _productProvider!.categories) {
        try {
          final foundProduct = category.products.firstWhere(
            (p) => p.id == productId,
          );
          currentProduct = foundProduct;
          break;
        } catch (e) {
          // Product not found in this category, continue to next
        }
      }
    }
    
    _items.remove(productId);
    
    // Update product quantity in the database (increase by removed quantity)
    if (currentProduct != null && _productProvider != null) {
      try {
        await _productProvider!.updateProductQuantity(productId, currentProduct.quantity + quantityToReturn);
      } catch (e) {
        print('Error updating product quantity: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> clear() async {
    // Return all quantities to inventory
    if (_productProvider != null) {
      for (var entry in _items.entries) {
        final productId = entry.key;
        final quantity = entry.value.quantity;
        
        // Find the product
        product_models.ProductData? currentProduct;
        for (var category in _productProvider!.categories) {
          try {
            final foundProduct = category.products.firstWhere(
              (p) => p.id == productId,
            );
            currentProduct = foundProduct;
            break;
          } catch (e) {
            // Product not found in this category, continue to next
          }
        }
        
        // Update product quantity in the database
        if (currentProduct != null) {
          try {
            await _productProvider!.updateProductQuantity(productId, currentProduct.quantity + quantity);
          } catch (e) {
            print('Error updating product quantity: $e');
          }
        }
      }
    }
    
    _items.clear();
    notifyListeners();
  }

  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }
}
