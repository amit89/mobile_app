import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService extends ChangeNotifier {
  String? _pincode;
  String? _address;
  bool _isLocationPermissionGranted = false;
  bool _isLoading = false;
  
  String? get pincode => _pincode;
  String? get address => _address;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  bool get isLoading => _isLoading;

  // Initialize location service
  Future<void> init() async {
    await _loadSavedLocation();
    await checkPermission();
  }
  
  // Check if location permission is granted
  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      _isLocationPermissionGranted = false;
    } else {
      _isLocationPermissionGranted = true;
    }
    
    notifyListeners();
    return _isLocationPermissionGranted;
  }
  
  // Request location permission
  Future<bool> requestPermission() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        _isLocationPermissionGranted = false;
      } else {
        _isLocationPermissionGranted = true;
        await getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      _isLocationPermissionGranted = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    return _isLocationPermissionGranted;
  }
  
  // Get current location and extract pincode
  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Check permission first
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10)
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Location request timed out');
          return Position(
            latitude: 0, 
            longitude: 0, 
            timestamp: DateTime.now(), 
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0
          );
        }
      );
      
      // Skip reverse geocoding if we got a timeout position
      if (position.latitude == 0 && position.longitude == 0) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Reverse geocode to get address details
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _pincode = place.postalCode;
        _address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        
        // Save location data
        await _saveLocation();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Save location to SharedPreferences
  Future<void> _saveLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_pincode != null) {
        await prefs.setString('user_pincode', _pincode!);
      }
      if (_address != null) {
        await prefs.setString('user_address', _address!);
      }
    } catch (e) {
      debugPrint('Error saving location data: $e');
    }
  }
  
  // Load saved location from SharedPreferences
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pincode = prefs.getString('user_pincode');
      _address = prefs.getString('user_address');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved location data: $e');
    }
  }
  
  // Manually set pincode
  Future<void> setPincode(String pincode) async {
    _pincode = pincode;
    await _saveLocation();
    notifyListeners();
  }
  
  // Manually set address
  Future<void> setAddress(String address) async {
    _address = address;
    await _saveLocation();
    notifyListeners();
  }
}
