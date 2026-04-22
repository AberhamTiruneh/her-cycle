import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  // ─── Instance Getters ─────────────────────────────────────────────────────

  FirebaseAuth get auth => FirebaseAuth.instance;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // ─── Initialization ───────────────────────────────────────────────────────

  /// Call once in main() before runApp.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') {
        // Log but don't crash — app will show auth error gracefully
        // ignore: avoid_print
        print('Firebase init error: ${e.code} — ${e.message}');
      }
    } catch (e) {
      // Catch any other init errors (e.g. missing iOS config)
      // ignore: avoid_print
      print('Firebase init error: $e');
    }

    // Firestore offline persistence is disabled until the Firebase database
    // is created in the console (https://console.cloud.google.com/datastore/setup).
    // Once the database exists, re-enable with persistenceEnabled: true.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  }

  // ─── Firestore Helpers ────────────────────────────────────────────────────

  /// Reference to a user's document.
  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      firestore.collection('users').doc(uid);

  /// Reference to a specific cycle document.
  DocumentReference<Map<String, dynamic>> cycleDoc(String cycleId) =>
      firestore.collection('cycles').doc(cycleId);

  /// Query all cycles belonging to [uid].
  Query<Map<String, dynamic>> userCycles(String uid) => firestore
      .collection('cycles')
      .where('userId', isEqualTo: uid)
      .orderBy('startDate', descending: true);

  // ─── Error Handling Wrapper ───────────────────────────────────────────────

  /// Executes [operation] and converts any [FirebaseException] into a
  /// human-readable [FirebaseServiceException].
  static Future<T> run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(_authMessage(e.code), code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        e.message ?? 'An unexpected Firebase error occurred.',
        code: e.code,
      );
    } catch (e) {
      throw FirebaseServiceException(e.toString());
    }
  }

  static String _authMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      default:
        return 'Authentication error: $code';
    }
  }
}

// ─── Custom Exception ──────────────────────────────────────────────────────

class FirebaseServiceException implements Exception {
  final String message;
  final String? code;

  const FirebaseServiceException(this.message, {this.code});

  @override
  String toString() => message;
}
