import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../widgets/location_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLocationRequest = false;
  
  @override
  void initState() {
    super.initState();
    _checkLocationAndNavigate();
  }
  
  Future<void> _checkLocationAndNavigate() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.init();
    
    // Wait a bit to show the splash screen
    await Future.delayed(const Duration(seconds: 1));
    
    if (!locationProvider.isLocationPermissionGranted) {
      // Show location permission request
      debugPrint('SplashScreen: Location permission not granted, showing request dialog');
      setState(() {
        _showLocationRequest = true;
      });
    } else {
      // If permission already granted, get location and navigate
      debugPrint('SplashScreen: Location permission already granted, proceeding to home');
      await locationProvider.getCurrentLocation();
      _navigateToHome();
    }
  }
  
  void _navigateToHome() {
    debugPrint('SplashScreen: Navigating to home');
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/logo/green_grab.jpeg',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading logo: $error');
                return Container(
                  width: 150,
                  height: 150,
                  color: Colors.white,
                  child: const Icon(Icons.image_not_supported, size: 50),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'GreenGrab',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Fresh groceries delivered fast',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            if (_showLocationRequest) ...[
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    LocationPermissionWidget(
                      onPermissionGranted: _navigateToHome,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _navigateToHome,
                      child: const Text('Skip for now'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}