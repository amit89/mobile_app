# GreenGrab - Grocery Delivery App

GreenGrab is a Flutter-based mobile application for grocery shopping and delivery, similar to Zepto/Blinkit. The app features a clean and intuitive interface for browsing products, managing cart, and placing orders.

## Features

- **Product Browsing**: Browse products by categories
- **Shopping Cart**: Add/remove items, adjust quantities
- **Checkout Process**: Simple checkout with delivery information
- **User Authentication**: Basic login functionality
- **State Management**: Using Provider for app-wide state management

## Screens

1. **Splash Screen** (`/`)
   - Initial loading screen
   - App logo and branding

2. **Login Screen** (`/login`)
   - User authentication
   - Email/Password login

3. **Home Screen** (`/home`)
   - Product categories
   - Product listings
   - Add to cart functionality
   - Navigation to cart and profile

4. **Cart Screen** (`/cart`)
   - View cart items
   - Adjust quantities
   - Remove items
   - View total amount
   - Proceed to checkout

5. **Checkout Screen** (`/checkout`)
   - Delivery information form
   - Name
   - Delivery Address
   - PIN Code
   - State (Haryana)
   - City (Gurugram)
   - Cash on Delivery option
   - Order summary with delivery fee

6. **Profile Screen** (`/profile`)
   - User profile information
   - Account settings

## Prerequisites

To run this application, you need to have the following installed:

1. **Flutter SDK** (Latest stable version)
   - [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

2. **Dart SDK** (Comes with Flutter)

3. **Android Studio** or **VS Code**
   - [Android Studio Download](https://developer.android.com/studio)
   - [VS Code Download](https://code.visualstudio.com/)

4. For iOS development:
   - macOS computer
   - Xcode (latest version)
   - iOS Simulator or physical device

5. For Android development:
   - Android SDK
   - Android Emulator or physical device
   - Android Studio

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd my_first_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Build Instructions

### Android

To build an Android APK:
```bash
flutter build apk
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

For an Android App Bundle:
```bash
flutter build appbundle
```

### iOS

To build for iOS (requires macOS):
```bash
flutter build ios
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

## To run the app 
```
flutter clean && flutter pub get && flutter run
```

## Project Structure

```
my_first_app/
├── lib/
│   ├── main.dart           # App entry point
│   ├── screens/            # Screen widgets
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   └── profile_screen.dart
│   ├── providers/          # State management
│   │   └── providers.dart
│   ├── models/            # Data models
│   └── widgets/           # Reusable widgets
├── assets/                # Images and fonts
├── test/                 # Test files
└── pubspec.yaml          # Dependencies
```

## Dependencies

- `flutter_sdk`: Latest stable version
- `provider`: ^6.0.5 (State management)
- `go_router`: ^12.1.1 (Navigation)
- `http`: ^1.1.0 (HTTP requests)
- `shared_preferences`: ^2.2.2 (Local storage)
- `cached_network_image`: ^3.3.0 (Image handling)

## Development Notes

- Uses Material Design 3
- Implements Provider pattern for state management
- Uses GoRouter for navigation
- Follows Flutter best practices and conventions
- Implements responsive design principles

## Future Enhancements

- [ ] Backend integration
- [ ] User authentication with backend
- [ ] Product search functionality
- [ ] Order history
- [ ] Multiple payment methods
- [ ] Address management
- [ ] Real-time order tracking

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Contact

Your Name - your.email@example.com
Project Link: [https://github.com/yourusername/my_first_app](https://github.com/yourusername/my_first_app)
