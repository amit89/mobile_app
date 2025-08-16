import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;

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

  // Values extracted from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCm4vbXt7h1_o69-V9NZGxGG3ZG1gxwFOw',
    appId: '1:800953781098:android:b9aea29ea3bbfd9232f313',
    messagingSenderId: '800953781098',
    projectId: 'greengrab-18e93',
    storageBucket: 'greengrab-18e93.firebasestorage.app',
    // Add SHA-1 certificate to help with phone authentication
    androidClientId: 'com.green.the_green_grab', // This is your package name
  );

  // You'll need to fill iOS values from your GoogleService-Info.plist
  // Using placeholder values for now
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '800953781098', // Same as Android
    projectId: 'greengrab-18e93', // Same as Android
    storageBucket: 'greengrab-18e93.firebasestorage.app', // Same as Android
  );
}
