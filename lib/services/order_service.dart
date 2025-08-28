import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get collection reference
  CollectionReference get _ordersCollection => _firestore.collection('orders');

  // Create a new order
  Future<String> createOrder(UserOrder order) async {
    try {
      final docRef = await _ordersCollection.add(order.toMap());
      
      // Update the document with its ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Get orders for a specific user
  Stream<List<UserOrder>> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return UserOrder.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Get a specific order by ID
  Future<UserOrder?> getOrderById(String orderId) async {
    try {
      final docSnapshot = await _ordersCollection.doc(orderId).get();
      
      if (docSnapshot.exists) {
        return UserOrder.fromMap(
          docSnapshot.data() as Map<String, dynamic>, 
          docSnapshot.id
        );
      }
      
      return null;
    } catch (e) {
      print('Error getting order by ID: $e');
      rethrow;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({'status': status});
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }
}
