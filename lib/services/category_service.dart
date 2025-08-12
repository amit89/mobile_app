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
      
      // If no categories found, return empty list
      if (snapshot.docs.isEmpty) {
        return categories;
      }
      
      for (var doc in snapshot.docs) {
        var categoryData = doc.data();
        categoryData['id'] = doc.id;  // Add the Firestore document ID to the data
        
        // Get products for this category
        var productsSnapshot = await _firestore
            .collection('products')
            .where('categoryId', isEqualTo: doc.id)
            .get();  // Get all products, including those that might be soft-deleted

        // Filter out any products that might still have isAvailable set to false
        List<ProductData> products = productsSnapshot.docs
            .map((productDoc) => ProductData.fromFirebase(productDoc.data()))
            .where((product) => product.isAvailable) // Add this filter to ensure only available products
            .toList();

        print('Found ${products.length} products for category ${categoryData['name']}');
        
        categories.add(CategoryData.fromFirebase(categoryData, products));
      }
      return categories;
    });
  }

  // Add a new category
  Future<DocumentReference<Map<String, dynamic>>> addCategory(CategoryData category) {
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
