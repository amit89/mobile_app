import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart' as providers;
import 'product_models.dart';

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
          leading: Text(
            product.image,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(product.name),
          subtitle: Text('₹${product.price}/${product.unit}'),
          trailing: ElevatedButton(
            onPressed: () {
              try {
                final cartProvider = Provider.of<providers.CartProvider>(context, listen: false);
                cartProvider.addToCart(providers.ProductData(
                  id: product.id,
                  name: product.name,
                  price: product.price,
                  image: product.image,
                  unit: product.unit,
                ));
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart!'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
          ),
        );
      },
    );
  }
}
