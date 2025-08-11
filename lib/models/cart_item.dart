class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;
  final String? categoryId;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    this.categoryId,
    this.quantity = 1,
  });

  double get total => price * quantity;
}
