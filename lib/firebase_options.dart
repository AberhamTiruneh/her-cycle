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
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0WsAMucOgyM7hxF7VNOIXPWs83cPbL5w',
    appId: '1:636783579179:ios:882789cec516d05f61da6e',
    messagingSenderId: '636783579179',
    projectId: 'her-cycle-a8b35',
    storageBucket: 'her-cycle-a8b35.firebasestorage.app',
    iosBundleId: 'com.yeab.hercycle',
  );
}
