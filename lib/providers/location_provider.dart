import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  LocationService get locationService => _locationService;
  
  String? get pincode => _locationService.pincode;
  String? get address => _locationService.address;
  bool get isLocationPermissionGranted => _locationService.isLocationPermissionGranted;
  bool get isLoading => _locationService.isLoading;
  
  LocationProvider() {
    init();
  }
  
  Future<void> init() async {
    await _locationService.init();
  }
  
  Future<bool> requestLocationPermission() async {
    return await _locationService.requestPermission();
  }
  
  Future<void> getCurrentLocation() async {
    await _locationService.getCurrentLocation();
  }
  
  Future<void> setPincode(String pincode) async {
    await _locationService.setPincode(pincode);
  }
  
  Future<void> setAddress(String address) async {
    await _locationService.setAddress(address);
  }
}
