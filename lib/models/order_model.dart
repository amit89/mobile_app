import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String unit;
  final int quantity;
  final double total;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.unit,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'unit': unit,
      'quantity': quantity,
      'total': total,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      image: map['image'] ?? '',
      unit: map['unit'] ?? '',
      quantity: map['quantity'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }
}

class UserOrder {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String deliveryAddress;
  final String name;
  final String pinCode;
  final String paymentMethod;
  final String status;

  UserOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.deliveryAddress,
    required this.name,
    required this.pinCode,
    required this.paymentMethod,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryAddress': deliveryAddress,
      'name': name,
      'pinCode': pinCode,
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }

  factory UserOrder.fromMap(Map<String, dynamic> map, String documentId) {
    return UserOrder(
      id: documentId,
      userId: map['userId'] ?? '',
      items: List<OrderItem>.from(
        (map['items'] as List? ?? []).map((item) => OrderItem.fromMap(item)),
      ),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      orderDate: (map['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryAddress: map['deliveryAddress'] ?? '',
      name: map['name'] ?? '',
      pinCode: map['pinCode'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Cash on Delivery',
      status: map['status'] ?? 'Pending',
    );
  }
}
