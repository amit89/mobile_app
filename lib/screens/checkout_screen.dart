import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart' as cart;
import '../providers/providers.dart';
import '../providers/location_provider.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/location_widgets.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillLocationData();
  }

  Future<void> _prefillLocationData() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // Prefill address and pincode if available
    if (locationProvider.address != null && locationProvider.address!.isNotEmpty) {
      _addressController.text = locationProvider.address!;
    }
    
    if (locationProvider.pincode != null && locationProvider.pincode!.isNotEmpty) {
      _pinCodeController.text = locationProvider.pincode!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<cart.CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Check if cart is empty
    if (cartProvider.items.isEmpty) {
      return Scaffold(
        appBar: const CommonAppBar(
          title: 'Checkout',
        ),
        body: const Center(
          child: Text('Your cart is empty'),
        ),
      );
    }

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please login to continue',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Information Section
              const Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Location display section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const LocationDisplay(),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                              await locationProvider.getCurrentLocation();
                              
                              // Update text fields with new location data
                              if (locationProvider.address != null && locationProvider.address!.isNotEmpty) {
                                _addressController.text = locationProvider.address!;
                              }
                              
                              if (locationProvider.pincode != null && locationProvider.pincode!.isNotEmpty) {
                                _pinCodeController.text = locationProvider.pincode!;
                              }
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.my_location, size: 16),
                                SizedBox(width: 4),
                                Text('Use current location'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your delivery address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Pin Code Field
              TextFormField(
                controller: _pinCodeController,
                decoration: const InputDecoration(
                  labelText: 'PIN Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PIN code';
                  }
                  if (value.length != 6) {
                    return 'PIN code must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // State and City Fields (Hardcoded)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: 'Haryana',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: 'Gurugram',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Payment Section
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Cash on Delivery Option
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.money,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items Total:'),
                        Text('₹${cartProvider.totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Fee:'),
                        Text('₹0.00'),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Get auth provider to get user ID
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final cartProvider = Provider.of<cart.CartProvider>(context, listen: false);
                
                // Initialize order service
                final orderService = OrderService();
                
                // Create order items from cart
                final orderItems = cartProvider.items.values.map((item) => 
                  OrderItem(
                    id: item.id,
                    name: item.name,
                    price: item.price,
                    image: item.image,
                    unit: item.unit,
                    quantity: item.quantity,
                    total: item.total,
                  )
                ).toList();
                
                // Create order object
                final order = UserOrder(
                  id: '', // Will be set by Firestore
                  userId: authProvider.userId!,
                  items: orderItems,
                  totalAmount: cartProvider.totalAmount,
                  orderDate: DateTime.now(),
                  deliveryAddress: _addressController.text,
                  name: _nameController.text,
                  pinCode: _pinCodeController.text,
                  paymentMethod: 'Cash on Delivery',
                  status: 'Pending',
                );
                
                try {
                  // Save order to Firestore
                  await orderService.createOrder(order);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order placed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Clear cart after successful order
                  cartProvider.clear();
                  
                  // Navigate to home screen
                  context.go('/home');
                } catch (e) {
                  print('Error placing order: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to place order: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Place Order - ₹${cartProvider.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
