import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product_models.dart';
import '../providers/cart_provider.dart' as cart;
import '../providers/product_provider.dart' as products;
import '../widgets/common_app_bar.dart';
import 'category_screen.dart';
import 'everything_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use this to make sure we're calling after the widget is fully built
      final productProvider = Provider.of<products.ProductProvider>(context, listen: false);
      productProvider.loadCategories();
      
      // Make sure the cart provider has the product provider
      final cartProvider = Provider.of<cart.CartProvider>(context, listen: false);
      print('HomeScreen: Ensuring CartProvider has ProductProvider reference');
      cartProvider.setProductProvider(productProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/logo/green_grab.jpeg',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text('GreenGrab'),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Don't show back button on home screen
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  Provider.of<products.ProductProvider>(context, listen: false)
                      .categories,
                ),
              );
            },
          ),
          Consumer<cart.CartProvider>(
            builder: (context, cartProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      context.go('/cart');
                    },
                  ),
                  if (cartProvider.totalItems > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<products.ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (productProvider.categories.isEmpty) {
            return const Center(
              child: Text('No categories available'),
            );
          }

          // Create a list view with Everything section at the top
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add the "Everything" section first
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EverythingCategoryScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Everything",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Calculate all products
                  Builder(
                    builder: (context) {
                      final allProducts = <ProductData>[];
                      for (var category in productProvider.categories) {
                        allProducts.addAll(category.products);
                      }
                      // Limit to first 5 products
                      final displayProducts = allProducts.length > 5 
                          ? allProducts.sublist(0, 5) 
                          : allProducts;
                      
                      return SizedBox(
                        height: 200,
                        child: displayProducts.isEmpty
                            ? const Center(child: Text('No products available'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: displayProducts.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(product: displayProducts[index]);
                                },
                              ),
                      );
                    }
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              // Then add all the regular categories
              ...productProvider.categories.map((category) => CategorySection(category: category)).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.go('/cart');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final CategoryData category;

  const CategorySection({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryScreen(category: category),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: category.products.length,
            itemBuilder: (context, index) {
              final product = category.products[index];
              return ProductCard(product: product);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductData product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                product.image,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product.price}/${product.unit}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<cart.CartProvider>(
                  builder: (context, cartProvider, _) {
                    final quantity = cartProvider.getQuantity(product.id);
                    return SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: product.quantity <= 0
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : quantity == 0
                          ? ElevatedButton(
                              onPressed: () async {
                                try {
                                  // Ensure the cart provider has a product provider reference
                                  final productProvider = Provider.of<products.ProductProvider>(context, listen: false);
                                  cartProvider.setProductProvider(productProvider);
                                  
                                  bool success = await cartProvider.addToCart(cart.ProductData(
                                    id: product.id,
                                    name: product.name,
                                    price: product.price,
                                    image: product.image,
                                    unit: product.unit,
                                    categoryId: product.categoryId,
                                    quantity: product.quantity,
                                  ));
                                  
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} added to cart!'),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sorry, ${product.name} is out of stock'),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to add item to cart'),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'ADD',
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: () => cartProvider.decrementQuantity(product.id),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () async {
                                      // Ensure the cart provider has a product provider reference
                                      final productProvider = Provider.of<products.ProductProvider>(context, listen: false);
                                      cartProvider.setProductProvider(productProvider);
                                      
                                      bool success = await cartProvider.addToCart(cart.ProductData(
                                        id: product.id,
                                        name: product.name,
                                        price: product.price,
                                        image: product.image,
                                        unit: product.unit,
                                        categoryId: product.categoryId,
                                        quantity: product.quantity,
                                      ));
                                      
                                      if (!success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Sorry, ${product.name} is out of stock'),
                                            duration: const Duration(seconds: 1),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<ProductData?> {
  final List<CategoryData> categories;

  ProductSearchDelegate(this.categories);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a product name to search'),
      );
    }

    final results = categories
        .expand((category) => category.products)
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          dense: true,
          leading: Text(
            product.image,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(
            product.name,
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            '₹${product.price}/${product.unit}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Consumer<cart.CartProvider>(
            builder: (context, cartProvider, _) {
              final quantity = cartProvider.getQuantity(product.id);
              return SizedBox(
                width: 110,
                child: quantity == 0
                    ? ElevatedButton(
                        onPressed: () {
                          try {
                            // Ensure the cart provider has a product provider reference
                            final productProvider = Provider.of<products.ProductProvider>(context, listen: false);
                            cartProvider.setProductProvider(productProvider);
                            
                            cartProvider.addToCart(cart.ProductData(
                              id: product.id,
                              name: product.name,
                              price: product.price,
                              image: product.image,
                              unit: product.unit,
                              categoryId: product.categoryId,
                            ));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to add item to cart'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('ADD'),
                      )
                    : Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () => cartProvider.decrementQuantity(product.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              quantity.toString(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                // Ensure the cart provider has a product provider reference
                                final productProvider = Provider.of<products.ProductProvider>(context, listen: false);
                                cartProvider.setProductProvider(productProvider);
                                
                                cartProvider.addToCart(cart.ProductData(
                                  id: product.id,
                                  name: product.name,
                                  price: product.price,
                                  image: product.image,
                                  unit: product.unit,
                                ));
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
        );
      },
    );
  }
}
