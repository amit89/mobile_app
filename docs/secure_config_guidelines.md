# Secure Handling of API Keys and Credentials in Flutter Production Apps

## Overview

This document outlines the recommended approaches for securely storing and managing API keys, secrets, and credentials in Flutter applications when releasing to the Android Play Store.

## Recommended Approaches

### 1. Use Flutter Secure Storage

Flutter Secure Storage uses platform-specific encryption mechanisms to securely store sensitive information:
- On Android: Keystore System
- On iOS: Keychain Services

### 2. CI/CD Pipeline with Environment Variables

For CI/CD pipelines (GitHub Actions, CircleCI, etc.):
1. Store secrets as encrypted environment variables in the CI system
2. Inject these values during the build process
3. Use the `--dart-define` flag to insert values at compile time:
   ```bash
   flutter build appbundle --dart-define=API_KEY=your_api_key
   ```
4. Access in code:
   ```dart
   const apiKey = String.fromEnvironment('API_KEY');
   ```

### 3. Native Code for Storing Secrets (Most Secure)

For highly sensitive keys, implement platform-specific native code:

**Android (Kotlin)**:
```kotlin
// Store in build.gradle or CMake files
buildTypes {
    release {
        buildConfigField "String", "API_KEY", "\"${getApiKey()}\""
    }
}

// Access via platform channels in Flutter
```

**iOS (Swift)**:
```swift
// Store in xcconfig files or Info.plist
// Access via platform channels in Flutter
```

### 4. Backend Proxy Service

Instead of storing API keys in the app:
1. Create a backend service that stores and manages API keys
2. App makes authenticated requests to your backend
3. Backend adds API keys before forwarding to third-party services
4. Use Firebase Cloud Functions or similar services for easier setup

### 5. Firebase Remote Config

For values that may change or need to be updated:
1. Store sensitive values in Firebase Remote Config
2. Use Firebase App Check to authenticate legitimate app instances
3. Implement proper authentication before returning sensitive values

## Simplified Implementation for Individual Development

### Step 1: Secure Storage Setup

1. **Add Flutter Secure Storage** to pubspec.yaml:
   ```yaml
   dependencies:
     flutter_secure_storage: ^9.0.0
   ```

2. **Create a config constants file** for development (keep this out of version control):
   ```dart
   // lib/config/dev_config.dart (add to .gitignore)
   class DevConfig {
     static const adminCredentials = {
       'userId': 'admin_user',
       'mobile': '7814260451',
       'email': 'admin@greengrab.com',
       'password': 'Sunday@30',
     };
     
     static const firebaseConfig = {
       'apiKey': 'AIzaSyCm4vbXt7h1_o69-V9NZGxGG3ZG1gxwFOw',
       'appId': '1:800953781098:android:b9aea29ea3bbfd9232f313',
       // other Firebase config values
     };
   }
   ```

3. **Initialize secure storage** at app startup:
   ```dart
   Future<void> _initializeSecureStorage() async {
     final secureStorage = FlutterSecureStorage();
     final hasStoredValues = await secureStorage.read(key: 'config_initialized') == 'true';
     
     if (!hasStoredValues) {
       // Store admin credentials
       await secureStorage.write(key: 'admin_user_id', value: DevConfig.adminCredentials['userId']);
       await secureStorage.write(key: 'admin_mobile', value: DevConfig.adminCredentials['mobile']);
       await secureStorage.write(key: 'admin_email', value: DevConfig.adminCredentials['email']);
       await secureStorage.write(key: 'admin_password', value: DevConfig.adminCredentials['password']);
       
       // Store Firebase config
       await secureStorage.write(key: 'firebase_api_key', value: DevConfig.firebaseConfig['apiKey']);
       await secureStorage.write(key: 'firebase_app_id', value: DevConfig.firebaseConfig['appId']);
       // Store other Firebase config values
       
       // Mark as initialized
       await secureStorage.write(key: 'config_initialized', value: 'true');
     }
   }

### Step 2: Access Values Securely

1. **Create a secure config service**:
   ```dart
   // lib/services/secure_config_service.dart
   class SecureConfigService {
     static final _instance = SecureConfigService._();
     final _storage = FlutterSecureStorage();
     
     factory SecureConfigService() => _instance;
     SecureConfigService._();
     
     // Get admin credentials
     Future<Map<String, String>> getAdminCredentials() async {
       return {
         'userId': await _storage.read(key: 'admin_user_id') ?? '',
         'mobile': await _storage.read(key: 'admin_mobile') ?? '',
         'email': await _storage.read(key: 'admin_email') ?? '',
         'password': await _storage.read(key: 'admin_password') ?? '',
       };
     }
     
     // Get Firebase options
     Future<FirebaseOptions> getFirebaseOptions() async {
       return FirebaseOptions(
         apiKey: await _storage.read(key: 'firebase_api_key') ?? '',
         appId: await _storage.read(key: 'firebase_app_id') ?? '',
         messagingSenderId: await _storage.read(key: 'firebase_messaging_sender_id') ?? '',
         projectId: await _storage.read(key: 'firebase_project_id') ?? '',
         storageBucket: await _storage.read(key: 'firebase_storage_bucket') ?? '',
       );
     }
     
     // Validate admin credentials
     Future<bool> validateAdminCredentials({
       required String phoneOrEmail, 
       required String password
     }) async {
       final credentials = await getAdminCredentials();
       return (phoneOrEmail == credentials['mobile'] || 
              phoneOrEmail == credentials['email']) && 
              password == credentials['password'];
     }
   }
   ```

### Step 3: Update Your Main App

1. **Initialize secure storage on app startup**:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Initialize secure storage
     await _initializeSecureStorage();
     
     // Initialize Firebase with secure config
     final secureConfig = SecureConfigService();
     await Firebase.initializeApp(
       options: await secureConfig.getFirebaseOptions(),
     );
     
     // Rest of your app initialization
     runApp(MyApp());
   }
   ```

2. **Update the auth provider** to use the secure config service:
   ```dart
   // In AuthProvider class
   final _secureConfig = SecureConfigService();
   
   Future<bool> login({required String emailOrMobile, required String password}) async {
     return _secureConfig.validateAdminCredentials(
       phoneOrEmail: emailOrMobile,
       password: password
     );
   }
   ```

## Security Best Practices for Individual Projects

1. Keep your dev_config.dart file in .gitignore to avoid exposing secrets
2. Use Flutter Secure Storage for sensitive values in the app
3. Enable app obfuscation when building for release:
   ```bash
   flutter build apk --obfuscate --split-debug-info=debug-info
   ```
4. Consider using Firebase App Check for additional API security
5. Implement basic certificate pinning for your API communications
6. Regularly update your app and dependencies to patch security vulnerabilities

## Practical Implementation Example

Let's create a minimal working example with the files you need:

### 1. Update .gitignore

Add the following to your `.gitignore` file:
```
# Sensitive configuration files
lib/config/dev_config.dart
lib/config/firebase_config.dart
```

### 2. Create a Template File

Create `lib/config/dev_config.template.dart`:
```dart
// TEMPLATE FILE: Copy to dev_config.dart and fill in your values
// DO NOT commit dev_config.dart to version control

class DevConfig {
  // Admin credentials
  static const adminCredentials = {
    'userId': 'ADMIN_USER_ID',
    'mobile': 'ADMIN_MOBILE',
    'email': 'ADMIN_EMAIL',
    'password': 'ADMIN_PASSWORD',
  };
  
  // Firebase configuration
  static const firebaseConfig = {
    'apiKey': 'FIREBASE_API_KEY',
    'appId': 'FIREBASE_APP_ID',
    'messagingSenderId': 'FIREBASE_MESSAGING_SENDER_ID',
    'projectId': 'FIREBASE_PROJECT_ID',
    'storageBucket': 'FIREBASE_STORAGE_BUCKET',
  };
}
```

### 3. Implement the Secure Service

This service manages all your secure configuration needs:
```dart
// lib/services/secure_config_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/dev_config.dart'; // This is your local file not in git

class SecureConfigService {
  static final SecureConfigService _instance = SecureConfigService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _initialized = false;
  
  factory SecureConfigService() {
    return _instance;
  }
  
  SecureConfigService._internal();
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Check if we need to set up the secure storage
    final hasConfig = await _storage.read(key: 'config_initialized') == 'true';
    
    if (!hasConfig) {
      // Store admin credentials
      await _storage.write(key: 'admin_user_id', value: DevConfig.adminCredentials['userId']);
      await _storage.write(key: 'admin_mobile', value: DevConfig.adminCredentials['mobile']);
      await _storage.write(key: 'admin_email', value: DevConfig.adminCredentials['email']);
      await _storage.write(key: 'admin_password', value: DevConfig.adminCredentials['password']);
      
      // Store Firebase config
      await _storage.write(key: 'firebase_api_key', value: DevConfig.firebaseConfig['apiKey']);
      await _storage.write(key: 'firebase_app_id', value: DevConfig.firebaseConfig['appId']);
      await _storage.write(key: 'firebase_messaging_sender_id', value: DevConfig.firebaseConfig['messagingSenderId']);
      await _storage.write(key: 'firebase_project_id', value: DevConfig.firebaseConfig['projectId']);
      await _storage.write(key: 'firebase_storage_bucket', value: DevConfig.firebaseConfig['storageBucket']);
      
      // Mark as initialized
      await _storage.write(key: 'config_initialized', value: 'true');
    }
    
    _initialized = true;
  }
  
  // Add methods to get values and validate credentials
}
```

## Testing Your Secure Implementation

1. Test secure storage initialization works properly
2. Verify admin login works using secure credentials
3. Ensure Firebase initializes correctly with secure options
4. Use a network proxy like Charles to verify keys aren't leaked

## Updating Credentials in Production

For your individual project without CI/CD:

1. Update values in `dev_config.dart` locally
2. Build a new release version with updated values
3. Or implement a simple version check mechanism to wipe and reset secure storage on app update
