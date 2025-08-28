import 'package:firebase_core/firebase_core.dart';
import 'secure_storage_config.dart';

/// A class that generates Firebase options from secure storage
class SecureFirebaseOptions {
  // Private constructor to prevent instantiation
  SecureFirebaseOptions._();
  
  /// Fetch Firebase options for the current platform
  static Future<FirebaseOptions> getCurrentPlatformOptions() async {
    final secureConfig = SecureStorageConfig();
    
    // Determine the platform using Dart's platform detection
    if (isAndroid()) {
      return _getAndroidOptions(secureConfig);
    } else if (isIOS()) {
      return _getIosOptions(secureConfig);
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  
  // Platform detection helpers
  static bool isAndroid() {
    return bool.fromEnvironment('dart.library.io') &&
           bool.fromEnvironment('dart.library.jni');
  }
  
  static bool isIOS() {
    return bool.fromEnvironment('dart.library.io') &&
           bool.fromEnvironment('dart.library.darwin');
  }

  /// Get Firebase options for Android from secure storage
  static Future<FirebaseOptions> getAndroidOptions() async {
    return _getAndroidOptions(SecureStorageConfig());
  }
  
  /// Get Firebase options for iOS from secure storage
  static Future<FirebaseOptions> getIosOptions() async {
    return _getIosOptions(SecureStorageConfig());
  }
  
  static Future<FirebaseOptions> _getAndroidOptions(SecureStorageConfig config) async {
    final androidConfig = await config.getAndroidConfig();
    
    return FirebaseOptions(
      apiKey: androidConfig['apiKey']!,
      appId: androidConfig['appId']!,
      messagingSenderId: androidConfig['messagingSenderId']!,
      projectId: androidConfig['projectId']!,
      storageBucket: androidConfig['storageBucket']!,
      // Add additional Android-specific options if needed
    );
  }
  
  static Future<FirebaseOptions> _getIosOptions(SecureStorageConfig config) async {
    final iosConfig = await config.getIosConfig();
    
    return FirebaseOptions(
      apiKey: iosConfig['apiKey']!,
      appId: iosConfig['appId']!,
      messagingSenderId: iosConfig['messagingSenderId']!,
      projectId: iosConfig['projectId']!,
      storageBucket: iosConfig['storageBucket']!,
      // Add additional iOS-specific options if needed
    );
  }
}
