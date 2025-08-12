import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_models.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all categories
  Stream<List<CategoryData>> getCategories() {
    print('CategoryService: Getting all categories');
    return _firestore
        .collection('categories')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<CategoryData> categories = [];
      
      // If no categories found, return empty list
      if (snapshot.docs.isEmpty) {
        print('CategoryService: No categories found');
        return categories;
      }
      
      print('CategoryService: Found ${snapshot.docs.length} categories');
      
      for (var doc in snapshot.docs) {
        var categoryData = doc.data();
        categoryData['id'] = doc.id;  // Add the Firestore document ID to the data
        
        print('CategoryService: Loading products for category: ${categoryData['name']}');
        
        // Get products for this category
        var productsSnapshot = await _firestore
            .collection('products')
            .where('categoryId', isEqualTo: doc.id)
            .where('isAvailable', isEqualTo: true)  // Only get available products
            .get();

        // Process product data
        List<ProductData> products = [];
        for (var productDoc in productsSnapshot.docs) {
          var productData = productDoc.data();
          productData['id'] = productDoc.id;  // Add the Firestore document ID
          
          // Create product object
          var product = ProductData.fromFirebase(productData);
          products.add(product);
        }

        // Print debugging info about products and quantities
        print('CategoryService: Found ${products.length} products for category ${categoryData['name']}');
        for (var product in products) {
          print('CategoryService: ${product.name}: quantity=${product.quantity}, available=${product.isAvailable}');
        }
        
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
