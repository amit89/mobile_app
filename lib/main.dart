import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/admin_screen.dart';
import 'providers/cart_provider.dart' as cart;
import 'providers/providers.dart';
import 'providers/providers.dart' show AuthProvider;
import 'providers/product_provider.dart' as products;
import 'providers/location_provider.dart';

import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Temporarily disable Firebase App Check until API is enabled
    // Uncomment once App Check API is enabled in Google Cloud Console
    // await FirebaseAppCheck.instance.activate(
    //   androidProvider: AndroidProvider.debug,
    //   appleProvider: AppleProvider.debug,
    // );
    
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        // Auth Provider should be first
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // Then, create the ProductProvider
        ChangeNotifierProvider(
          create: (_) => products.ProductProvider(),
        ),
        // Then, create the CartProvider using the ProductProvider
        ChangeNotifierProxyProvider<products.ProductProvider, cart.CartProvider>(
          create: (_) => cart.CartProvider(),
          update: (_, productProvider, previousCartProvider) {
            final cartProvider = previousCartProvider ?? cart.CartProvider();
            cartProvider.setProductProvider(productProvider);
            print('Main: Setting ProductProvider in CartProvider');
            return cartProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // Location Provider
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          // Load categories when navigating to home
          Provider.of<products.ProductProvider>(context, listen: false).loadCategories();
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GreenGrab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}