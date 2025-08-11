import 'package:cloud_firestore/cloud_firestore.dart';

class ProductData {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;
  final String categoryId;
  final bool isAvailable;

  ProductData({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    required this.categoryId,
    this.isAvailable = true,
  });

  factory ProductData.fromFirebase(Map<String, dynamic> data) {
    return ProductData(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      image: data['image'] ?? '',
      unit: data['unit'] ?? '',
      categoryId: data['categoryId'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
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
