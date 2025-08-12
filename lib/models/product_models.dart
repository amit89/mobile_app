import 'package:cloud_firestore/cloud_firestore.dart';

class ProductData {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;
  final String categoryId;
  final bool isAvailable;
  final int quantity;

  ProductData({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    required this.categoryId,
    this.isAvailable = true,
    this.quantity = 0,
  });

  factory ProductData.fromFirebase(Map<String, dynamic> data) {
    // Handle quantity correctly regardless of its type in Firestore
    int quantity = 0;
    if (data['quantity'] != null) {
      if (data['quantity'] is int) {
        quantity = data['quantity'];
      } else if (data['quantity'] is double) {
        quantity = data['quantity'].toInt();
      } else if (data['quantity'] is String) {
        quantity = int.tryParse(data['quantity']) ?? 0;
      }
    }
    
    print('Loading product ${data['name']} from Firebase, raw quantity type: ${data['quantity']?.runtimeType}, raw value: ${data['quantity']}, parsed quantity: $quantity');
    
    return ProductData(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      image: data['image'] ?? '',
      unit: data['unit'] ?? '',
      categoryId: data['categoryId'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'unit': unit,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'quantity': quantity,
    };
  }
}

class CategoryData {
  final String id;
  final String name;
  final List<ProductData> products;
  final bool isAvailable;

  CategoryData({
    required this.id,
    required this.name,
    required this.products,
    this.isAvailable = true,
  });

  factory CategoryData.fromFirebase(Map<String, dynamic> data, List<ProductData> products) {
    return CategoryData(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      products: products,
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isAvailable': isAvailable,
    };
  }
}
