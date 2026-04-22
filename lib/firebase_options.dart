import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    throw UnsupportedError('Firebase not supported on this platform.');
  }

  // ─── Android ──────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5F5DuF0t3Y__fZ-_jhIWzlcAGg2dSBzY',
    appId: '1:636783579179:android:ed034ca8613267b661da6e',
    messagingSenderId: '636783579179',
    projectId: 'her-cycle-a8b35',
    storageBucket: 'her-cycle-a8b35.firebasestorage.app',
  );

  // ─── iOS ──────────────────────────────────────────────────────────────────
  // TODO: Replace with real iOS values from Firebase Console
  // Steps: https://console.firebase.google.com/project/her-cycle-a8b35/
  //   → Add app → iOS → bundle ID: com.yeab.hercycle
  //   → Download GoogleService-Info.plist → copy to ios/Runner/
  //   → Replace the values below with those from the plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '636783579179',
    projectId: 'her-cycle-a8b35',
    storageBucket: 'her-cycle-a8b35.firebasestorage.app',
    iosBundleId: 'com.yeab.hercycle',
  );
}
