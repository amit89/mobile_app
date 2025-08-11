import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Stream<List<ProductData>> getProducts() {
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductData.fromFirebase(doc.data()))
          .toList();
    });
  }

  // Get products by category
  Stream<List<ProductData>> getProductsByCategory(String categoryId) {
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductData.fromFirebase(doc.data()))
          .toList();
    });
  }

  // Add a new product
  Future<void> addProduct(ProductData product) {
    return _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toMap());
  }

  // Update a product
  Future<void> updateProduct(ProductData product) {
    return _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  // Delete a product
  Future<void> deleteProduct(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .update({'isAvailable': false});
  }
}
