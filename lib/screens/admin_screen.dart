import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/product_models.dart';
import '../providers/product_provider.dart' as products;

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
        // Load existing categories first
        productProvider.loadCategories();
        
        // Check after a short delay if categories were loaded
        Future.delayed(const Duration(milliseconds: 500), () {
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
      final category = CategoryData(
        id: 'cat_${DateTime.now().millisecondsSinceEpoch}_${defaultCategories.indexOf(categoryName)}',
        name: categoryName,
        products: [],
      );
      
      try {
        await productProvider.addCategory(category);
        newCategories.add(category);
        print('Added category: ${category.name}');
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
    // Ensure we have the latest categories
    final productProvider = Provider.of<products.ProductProvider>(context, listen: false);
    
    // If categories are empty, try to load them again
    if (productProvider.categories.isEmpty) {
      productProvider.loadCategories();
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
                    
                    // If we have categories but no selection, select the first one
                    if (_selectedCategoryId.isEmpty && productProvider.categories.isNotEmpty) {
                      _selectedCategoryId = productProvider.categories.first.id;
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
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
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the home screen using GoRouter
            context.go('/home');
          },
        ),
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

          return DefaultTabController(
            length: productProvider.categories.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: productProvider.categories.map((category) {
                    return Tab(text: category.name);
                  }).toList(),
                  labelColor: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: TabBarView(
                    children: productProvider.categories.map((category) {
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