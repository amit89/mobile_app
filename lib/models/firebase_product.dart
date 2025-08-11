class FirebaseProduct {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;
  final String categoryId;
  final bool isAvailable;

  FirebaseProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    required this.categoryId,
    this.isAvailable = true,
  });

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

  factory FirebaseProduct.fromMap(Map<String, dynamic> map) {
    return FirebaseProduct(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      image: map['image'] ?? '',
      unit: map['unit'] ?? '',
      categoryId: map['categoryId'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
