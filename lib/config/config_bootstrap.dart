import 'secure_storage_config.dart';

/// This file is used to bootstrap sensitive configurations.
/// It should be run once on app installation or after an update
/// to ensure all secure values are properly stored.
class ConfigBootstrap {
  /// Call this method during app initialization to set up secure config values
  static Future<void> initialize() async {
    final secureConfig = SecureStorageConfig();
    
    // Store admin credentials
    await secureConfig.storeAdminCredentials(
      userId: 'admin_user',
      mobile: '7814260451',
      email: 'admin@greengrab.com',
      password: 'Sunday@30',
    );
    
    // Store Firebase configuration
    await secureConfig.storeFirebaseConfig(
      androidConfig: {
        'apiKey': 'AIzaSyCm4vbXt7h1_o69-V9NZGxGG3ZG1gxwFOw',
        'appId': '1:800953781098:android:b9aea29ea3bbfd9232f313',
        'messagingSenderId': '800953781098',
        'projectId': 'greengrab-18e93',
        'storageBucket': 'greengrab-18e93.firebasestorage.app',
        'clientId': 'com.green.the_green_grab',
      },
      iosConfig: {
        'apiKey': 'YOUR_IOS_API_KEY',
        'appId': 'YOUR_IOS_APP_ID',
        'messagingSenderId': '800953781098',
        'projectId': 'greengrab-18e93',
        'storageBucket': 'greengrab-18e93.firebasestorage.app',
      },
    );
  }
}
