import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_models.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all categories
  Stream<List<CategoryData>> getCategories() {
    return _firestore
        .collection('categories')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<CategoryData> categories = [];
      for (var doc in snapshot.docs) {
        var categoryData = doc.data();
        
        // Get products for this category
        var productsSnapshot = await _firestore
            .collection('products')
            .where('categoryId', isEqualTo: doc.id)
            .where('isAvailable', isEqualTo: true)
            .get();

        List<ProductData> products = productsSnapshot.docs
            .map((productDoc) => ProductData.fromFirebase(productDoc.data()))
            .toList();

        categories.add(CategoryData.fromFirebase(categoryData, products));
      }
      return categories;
    });
  }

  // Add a new category
  Future<DocumentReference> addCategory(CategoryData category) {
    return _firestore.collection('categories').add(category.toMap());
  }

  // Update a category
  Future<void> updateCategory(CategoryData category) {
    return _firestore
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  // Delete a category (soft delete)
  Future<void> deleteCategory(String categoryId) {
    return _firestore
        .collection('categories')
        .doc(categoryId)
        .update({'isAvailable': false});
  }
}
