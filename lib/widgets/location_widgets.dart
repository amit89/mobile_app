import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class LocationPermissionWidget extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  
  const LocationPermissionWidget({
    super.key, 
    this.onPermissionGranted,
  });

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'To provide you with the best service, we need access to your location.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: locationProvider.isLoading
              ? null
              : () async {
                  final granted = await locationProvider.requestLocationPermission();
                  if (granted) {
                    await locationProvider.getCurrentLocation();
                    // Call the callback when permission is granted
                    if (onPermissionGranted != null) {
                      onPermissionGranted!();
                    }
                  }
                },
          child: locationProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Allow Location Access'),
        ),
      ],
    );
  }
}

class LocationDisplay extends StatelessWidget {
  const LocationDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
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
                  const SizedBox(height: 4),
                  if (locationProvider.pincode != null)
                    Text(
                      'PIN: ${locationProvider.pincode}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  if (locationProvider.address != null)
                    Text(
                      locationProvider.address!,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => locationProvider.getCurrentLocation(),
              child: const Text('Update'),
            ),
          ],
        ),
      ],
    );
  }
}
