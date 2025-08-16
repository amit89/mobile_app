import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import '../config/firebase_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    } else if (Platform.isIOS) {
      return ios;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Values loaded from config file
  static final FirebaseOptions android = FirebaseOptions(
    apiKey: FirebaseConfig.androidApiKey,
    appId: FirebaseConfig.androidAppId,
    messagingSenderId: FirebaseConfig.androidMessagingSenderId,
    projectId: FirebaseConfig.androidProjectId,
    storageBucket: FirebaseConfig.androidStorageBucket,
    // Add SHA-1 certificate to help with phone authentication
    androidClientId: FirebaseConfig.androidClientId,
  );

  // Values loaded from config file
  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: FirebaseConfig.iosApiKey,
    appId: FirebaseConfig.iosAppId,
    messagingSenderId: FirebaseConfig.iosMessagingSenderId,
    projectId: FirebaseConfig.iosProjectId,
    storageBucket: FirebaseConfig.iosStorageBucket,
  );
}
