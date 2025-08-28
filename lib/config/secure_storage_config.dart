import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageConfig {
  static final SecureStorageConfig _instance = SecureStorageConfig._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory SecureStorageConfig() {
    return _instance;
  }

  SecureStorageConfig._internal();

  // Methods to securely store and retrieve sensitive data
  Future<void> storeAdminCredentials({
    required String userId,
    required String mobile,
    required String email,
    required String password
  }) async {
    await _storage.write(key: 'admin_user_id', value: userId);
    await _storage.write(key: 'admin_mobile', value: mobile);
    await _storage.write(key: 'admin_email', value: email);
    await _storage.write(key: 'admin_password', value: password);
  }

  Future<Map<String, String>> getAdminCredentials() async {
    return {
      'userId': await _storage.read(key: 'admin_user_id') ?? '',
      'mobile': await _storage.read(key: 'admin_mobile') ?? '',
      'email': await _storage.read(key: 'admin_email') ?? '',
      'password': await _storage.read(key: 'admin_password') ?? '',
    };
  }

  // Method to validate admin credentials securely
  Future<bool> validateAdminCredentials({
    required String phoneOrEmail, 
    required String password
  }) async {
    final credentials = await getAdminCredentials();
    return (phoneOrEmail == credentials['mobile'] || 
            phoneOrEmail == credentials['email']) && 
            password == credentials['password'];
  }

  // Methods for Firebase configuration
  Future<void> storeFirebaseConfig({
    required Map<String, String> androidConfig,
    required Map<String, String> iosConfig,
  }) async {
    // Store Android config
    for (final entry in androidConfig.entries) {
      await _storage.write(key: 'android_${entry.key}', value: entry.value);
    }
    
    // Store iOS config
    for (final entry in iosConfig.entries) {
      await _storage.write(key: 'ios_${entry.key}', value: entry.value);
    }
  }

  Future<Map<String, String>> getAndroidConfig() async {
    return {
      'apiKey': await _storage.read(key: 'android_apiKey') ?? '',
      'appId': await _storage.read(key: 'android_appId') ?? '',
      'messagingSenderId': await _storage.read(key: 'android_messagingSenderId') ?? '',
      'projectId': await _storage.read(key: 'android_projectId') ?? '',
      'storageBucket': await _storage.read(key: 'android_storageBucket') ?? '',
      'clientId': await _storage.read(key: 'android_clientId') ?? '',
    };
  }

  Future<Map<String, String>> getIosConfig() async {
    return {
      'apiKey': await _storage.read(key: 'ios_apiKey') ?? '',
      'appId': await _storage.read(key: 'ios_appId') ?? '',
      'messagingSenderId': await _storage.read(key: 'ios_messagingSenderId') ?? '',
      'projectId': await _storage.read(key: 'ios_projectId') ?? '',
      'storageBucket': await _storage.read(key: 'ios_storageBucket') ?? '',
    };
  }
}
