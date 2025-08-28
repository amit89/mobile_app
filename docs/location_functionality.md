# Location Functionality Implementation

This implementation adds location functionality to the app, allowing it to:

1. Request location permission when the app starts
2. Automatically retrieve the user's pincode based on their location
3. Use the retrieved location data to pre-fill checkout fields
4. Display the current delivery location in the app header

## Features Added

- **Location Service**: Core service to handle location requests and permissions
- **Location Provider**: Provider to expose location data to the app
- **Permission Dialog**: UI to request location permission from the user
- **Location Display**: UI components to display location information

## How to Test

1. Run the app
2. The splash screen will show a location permission dialog
3. Choose "Allow Location Access" to grant permission
4. The app will automatically get your location and extract your pincode
5. On the home screen, your pincode will be displayed in the header
6. Navigate to the checkout page to see your address and pincode pre-filled

## Implementation Details

### Files Created/Modified:

- Added location service: `lib/services/location_service.dart`
- Added location provider: `lib/providers/location_provider.dart`
- Added location widgets: `lib/widgets/location_widgets.dart`
- Modified splash screen to request permission: `lib/screens/splash_screen.dart`
- Modified checkout screen to use location data: `lib/screens/checkout_screen.dart`
- Modified home screen to display location: `lib/screens/home_screen.dart`
- Added location permissions to Android Manifest and iOS Info.plist

### Dependencies Added:

- `geolocator`: For accessing device location
- `geocoding`: For reverse geocoding (converting coordinates to address/pincode)

## Technical Notes

- The location is automatically saved to SharedPreferences for future use
- The app works even if location permission is denied (manual input still available)
- Full address (including street, city, etc.) is extracted for better user experience
- Timeout handling is implemented to prevent the app from hanging if location services are slow
- The app automatically navigates to the home screen after location permission is granted

## Troubleshooting

If you encounter any issues with the location functionality:

1. **App doesn't navigate to home screen after granting permission**:
   - Check if the permission dialog from the OS appears and is properly handled
   - Verify that you're running on a physical device or an emulator with Google Play Services
   - Try clearing app data and reinstalling

2. **Location is not accurately detected**:
   - Ensure you have a stable internet connection for geocoding
   - Try moving to a location with better GPS signal
   - Enable high-accuracy mode in your device location settings
