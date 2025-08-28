import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
// This import is commented out since the file doesn't exist yet
// You must copy dev_config.template.dart to dev_config.dart and uncomment this line
// import '../config/dev_config.dart';

// TEMPORARY placeholder until you create your dev_config.dart file
// In a real implementation, you would import this from dev_config.dart
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
    'messagingSenderId': '800953781098',
    'projectId': 'greengrab-18e93',
    'storageBucket': 'greengrab-18e93.firebasestorage.app',
  };
}

/// A service for securely handling sensitive configuration
/// This includes API keys, credentials, and other secrets
class SecureConfigService {
  static final SecureConfigService _instance = SecureConfigService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _initialized = false;
  
  /// Factory constructor to return the singleton instance
  factory SecureConfigService() {
    return _instance;
  }
  
  /// Private constructor
  SecureConfigService._internal();
  
  /// Initialize the secure storage with values from the development config
  /// This should be called once when the app starts
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Check if we need to set up the secure storage
      final hasConfig = await _storage.read(key: 'config_initialized') == 'true';
      
      if (!hasConfig) {
        print('Initializing secure configuration storage...');
        
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
        print('Secure configuration initialized successfully.');
      }
      
      _initialized = true;
    } catch (e) {
      print('Error initializing secure configuration: $e');
      // You might want to handle this error more gracefully
    }
  }
  
  /// Get admin credentials as a map
  Future<Map<String, String>> getAdminCredentials() async {
    if (!_initialized) await initialize();
    
    return {
      'userId': await _storage.read(key: 'admin_user_id') ?? '',
      'mobile': await _storage.read(key: 'admin_mobile') ?? '',
      'email': await _storage.read(key: 'admin_email') ?? '',
      'password': await _storage.read(key: 'admin_password') ?? '',
    };
  }
  
  /// Get Firebase options for initialization
  Future<FirebaseOptions> getFirebaseOptions() async {
    if (!_initialized) await initialize();
    
    return FirebaseOptions(
      apiKey: await _storage.read(key: 'firebase_api_key') ?? '',
      appId: await _storage.read(key: 'firebase_app_id') ?? '',
      messagingSenderId: await _storage.read(key: 'firebase_messaging_sender_id') ?? '',
      projectId: await _storage.read(key: 'firebase_project_id') ?? '',
      storageBucket: await _storage.read(key: 'firebase_storage_bucket') ?? '',
    );
  }
  
  /// Validate admin credentials securely
  Future<bool> validateAdminCredentials({
    required String phoneOrEmail, 
    required String password
  }) async {
    if (!_initialized) await initialize();
    
    final credentials = await getAdminCredentials();
    return (phoneOrEmail == credentials['mobile'] || 
           phoneOrEmail == credentials['email']) && 
           password == credentials['password'];
  }
  
  /// Force update configuration (useful when credentials change)
  Future<void> forceUpdate() async {
    await _storage.delete(key: 'config_initialized');
    _initialized = false;
    await initialize();
  }
}
