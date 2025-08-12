import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/product_models.dart';
import '../providers/product_provider.dart' as products;
import '../widgets/common_app_bar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  String _image = '';
  String _unit = '';
  String _selectedCategoryId = '';

  @override
  void initState() {
    super.initState();
    // Initialize the selected category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<products.ProductProvider>(context, listen: false);
      
      try {
        // Clean up any soft-deleted products first
        productProvider.cleanupSoftDeletedProducts();
        
        // Load existing categories
        productProvider.loadCategories();
        
        // Check after a short delay if categories were loaded
        Future.delayed(const Duration(milliseconds: 1000), () {
          print('Categories loaded: ${productProvider.categories.length}');
          if (productProvider.categories.isEmpty) {
            print('No categories found, initializing defaults');
            _initializeDefaultCategories(productProvider);
          } else if (productProvider.categories.isNotEmpty) {
            print('Setting selected category to first: ${productProvider.categories.first.name}');
            setState(() {
              _selectedCategoryId = productProvider.categories.first.id;
            });
          }
        });
      } catch (e) {
        print('Error loading categories: $e');
        // If there's an error loading from Firebase, fall back to local categories
        _initializeDefaultCategories(productProvider);
      }
    });
  }

  void _initializeDefaultCategories(products.ProductProvider productProvider) async {
    final defaultCategories = [
      'Kitchen Essentials',
      'Breakfast Essentials',
      'Home Care',
      'Personal Care',
      'Snacks',
      'Others',
    ];

    // Clear any existing categories first to avoid duplicates
    print('Initializing default categories: ${defaultCategories.length}');
    
    List<CategoryData> newCategories = [];
    
    for (var categoryName in defaultCategories) {
      // Create a category with empty ID - Firestore will assign the ID
      final category = CategoryData(
        id: '',  // This will be replaced by Firestore document ID
        name: categoryName,
        products: [],
      );
      
      try {
        // Add the category to Firestore and get the document reference
        final docRef = await productProvider.addCategory(category);
        final firestoreId = docRef.id;
        
        print('Added category: ${category.name} with Firestore ID: $firestoreId');
        
        // Create an updated category with the Firestore ID
        final updatedCategory = CategoryData(
          id: firestoreId,
          name: categoryName,
          products: [],
        );
        
        // Update the category in Firestore with its own ID
        await productProvider.updateCategory(updatedCategory);
        
        newCategories.add(updatedCategory);
        
        // Add a small delay between category additions
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('Error adding category ${category.name}: $e');
      }
    }
    
    // Set the selected category after all categories are added
    if (newCategories.isNotEmpty) {
      setState(() {
        print('Setting selected category ID to: ${newCategories.first.id}');
        _selectedCategoryId = newCategories.first.id;
      });
    }
  }

  void _showAddProductDialog(BuildContext context) {
    // Reset form fields
    _name = '';
    _price = 0.0;
    _image = '';
    _unit = '';
    
    // Ensure we have the latest categories
    final productProvider = Provider.of<products.ProductProvider>(context, listen: false);
    
    // If categories are empty, try to load them again
    if (productProvider.categories.isEmpty) {
      productProvider.loadCategories();
    }
    
    // Validate selected category ID against available categories
    if (productProvider.categories.isNotEmpty) {
      bool categoryExists = productProvider.categories.any((c) => c.id == _selectedCategoryId);
      if (!categoryExists) {
        _selectedCategoryId = productProvider.categories.first.id;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<products.ProductProvider>(
                  builder: (context, productProvider, _) {
                    print('Categories available: ${productProvider.categories.length}');
                    
                    // Reset selection if categories change and current selection is not valid
                    if (productProvider.categories.isNotEmpty && 
                        !productProvider.categories.any((c) => c.id == _selectedCategoryId)) {
                      _selectedCategoryId = productProvider.categories.first.id;
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: productProvider.categories.any((c) => c.id == _selectedCategoryId) 
                             ? _selectedCategoryId 
                             : null,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: productProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    );
                  }
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _name = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _price = double.tryParse(value ?? '0') ?? 0,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Unit (kg, piece, etc)',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => _unit = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter unit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Image (emoji)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter an emoji (e.g., 🍎)',
                  ),
                  onSaved: (value) => _image = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an emoji';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final productProvider = Provider.of<products.ProductProvider>(
                  context,
                  listen: false,
                );

                final newProduct = ProductData(
                  id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                  name: _name,
                  price: _price,
                  image: _image,
                  unit: _unit,
                  categoryId: _selectedCategoryId,
                );

                try {
                  productProvider.addProduct(newProduct);
                  
                  // Reset form fields
                  _name = '';
                  _price = 0.0;
                  _image = '';
                  _unit = '';
                  _formKey.currentState!.reset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Admin Dashboard',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
      body: Consumer<products.ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.categories.isEmpty) {
            return const Center(
              child: Text('No categories available. Please add categories first.'),
            );
          }

          // Create a list of all products across all categories
          final allProducts = <ProductData>[];
          for (var category in productProvider.categories) {
            allProducts.addAll(category.products);
          }
          
          print('All products count: ${allProducts.length}');
          
          // Sort all products by name for better organization
          allProducts.sort((a, b) => a.name.compareTo(b.name));

          return DefaultTabController(
            // +1 for the "Everything" tab
            length: productProvider.categories.length + 1,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: [
                    // Add "Everything" tab first
                    const Tab(text: "Everything"),
                    // Then add the rest of the category tabs
                    ...productProvider.categories.map((category) {
                      return Tab(text: category.name);
                    }).toList(),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // "Everything" tab content
                      allProducts.isEmpty
                          ? const Center(child: Text('No products available'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: allProducts.length,
                              itemBuilder: (context, index) {
                                final product = allProducts[index];
                                // Find the category name for this product
                                final categoryName = productProvider.categories
                                    .firstWhere(
                                      (cat) => cat.id == product.categoryId,
                                      orElse: () => CategoryData(id: '', name: 'Unknown', products: []),
                                    )
                                    .name;
                                
                                return Card(
                                  child: ListTile(
                                    leading: Text(
                                      product.image,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    title: Text(product.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('₹${product.price}/${product.unit}'),
                                        Text('Category: $categoryName', 
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        productProvider.deleteProduct(product.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Product deleted'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                      // Individual category tabs
                      ...productProvider.categories.map((category) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: category.products.length,
                          itemBuilder: (context, index) {
                            final product = category.products[index];
                            return Card(
                              child: ListTile(
                                leading: Text(
                                  product.image,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(product.name),
                                subtitle: Text('₹${product.price}/${product.unit}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    productProvider.deleteProduct(product.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Product deleted'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}