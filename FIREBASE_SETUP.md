# Firebase Setup Instructions

## 1. Android — google-services.json

1. Open [Firebase Console](https://console.firebase.google.com) and select your project.
2. Go to **Project Settings → Your Apps → Android app**.
3. Register the package name: `com.example.her_cycle` (or your actual package name in `android/app/build.gradle`).
4. Download **google-services.json**.
5. Place the file at:

```
android/app/google-services.json
```

6. Ensure `android/build.gradle` contains:
```groovy
classpath 'com.google.gms:google-services:4.4.0'
```

7. Ensure `android/app/build.gradle` contains at the bottom:
```groovy
apply plugin: 'com.google.gms.google-services'
```

---

## 2. iOS — GoogleService-Info.plist

1. In the same Firebase Console, add an **iOS app**.
2. Register the bundle ID from `ios/Runner.xcodeproj` (e.g. `com.example.herCycle`).
3. Download **GoogleService-Info.plist**.
4. In Xcode, drag the file into the `Runner` target (check **Copy items if needed**).
5. The file should appear at:

```
ios/Runner/GoogleService-Info.plist
```

---

## 3. Firebase Authentication — Enable Providers

In Firebase Console → **Authentication → Sign-in method**, enable:
- Email/Password
- Google

---

## 4. Cloud Firestore — Create Database

1. Firebase Console → **Firestore Database → Create database**.
2. Start in **production mode**.
3. Choose a region close to your users.
4. Apply the security rules from `firestore.rules` in the **Rules** tab.

---

## 5. Firebase Messaging (Push Notifications)

### Android
Add to `android/app/src/main/AndroidManifest.xml` inside `<application>`:
```xml
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="false">
  <intent-filter>
    <action android:name="com.google.firebase.MESSAGING_EVENT"/>
  </intent-filter>
</service>
```

### iOS
Enable **Push Notifications** and **Background Modes → Remote notifications**
capabilities in Xcode.

---

## 6. SHA-1 Fingerprint (Google Sign-In on Android)

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Add the SHA-1 to your Android app in Firebase Console → Project Settings.
