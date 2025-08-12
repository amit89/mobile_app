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
    print('Adding product to Firebase: ${product.name}, quantity: ${product.quantity}');
    
    final productMap = product.toMap();
    print('Product data for Firebase: $productMap');
    
    return _firestore
        .collection('products')
        .doc(product.id)
        .set(productMap);
  }

  // Update a product
  Future<void> updateProduct(ProductData product) {
    print('Updating product in Firebase: ${product.name}, quantity: ${product.quantity}');
    
    final productMap = product.toMap();
    print('Updated product data for Firebase: $productMap');
    
    return _firestore
        .collection('products')
        .doc(product.id)
        .update(productMap);
  }

  // Get products that were previously soft-deleted (isAvailable = false)
  Future<List<ProductData>> getSoftDeletedProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: false)
        .get();
    
    return snapshot.docs
        .map((doc) => ProductData.fromFirebase(doc.data()))
        .toList();
  }

  // Delete a product
  Future<void> deleteProduct(String productId) {
    // Perform a hard delete instead of a soft delete
    return _firestore
        .collection('products')
        .doc(productId)
        .delete();
  }
}
