import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_service.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseService.instance.auth;
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── Auth State ───────────────────────────────────────────────────────────

  /// Stream that emits whenever the signed-in user changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently signed-in [User], or null.
  User? getCurrentUser() => _auth.currentUser;

  /// Returns true if a user is currently signed in.
  bool isLoggedIn() => _auth.currentUser != null;

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    return FirebaseService.run(() async {
      // Create Firebase Auth account — this is the critical step.
      // If this fails, an appropriate error is thrown to the caller.
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      // Update display name — best-effort (a network hiccup here must not
      // prevent the account from being usable).
      try {
        await user.updateDisplayName(name);
      } catch (_) {}

      // Build Firestore document
      final now = Timestamp.now();
      final userData = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        language: 'en',
        themeMode: 'light',
        notificationsEnabled: true,
        smsAlertsEnabled: false,
        reminderDaysBefore: 3,
        createdAt: now.toDate(),
      );

      // Write to Firestore — best-effort. If this fails the auth stream
      // handler will create the document on next app start via
      // loadOrCreateUserProfile().
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userData.toFirestore());
      } catch (_) {}

      return userData;
    });
  }

  // ─── Sign In ──────────────────────────────────────────────────────────────

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return FirebaseService.run(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      // Firestore fetch is best-effort — if rules aren't deployed or the
      // database doesn't exist yet, fall back to Firebase Auth data so the
      // user can still log in.
      try {
        return await _fetchOrCreateUserDoc(user);
      } catch (_) {
        return UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          createdAt: DateTime.now(),
        );
      }
    });
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<UserModel> signInWithGoogle() async {
    return FirebaseService.run(() async {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const FirebaseServiceException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return _fetchOrCreateUserDoc(result.user!);
    });
  }

  // ─── Anonymous Sign-In ─────────────────────────────────────────────────────

  Future<UserModel> signInAnonymously() async {
    return FirebaseService.run(() async {
      final credential = await _auth.signInAnonymously();
      return UserModel(
        uid: credential.user!.uid,
        name: 'Guest',
        email: '',
        phoneNumber: '',
        createdAt: DateTime.now(),
      );
    });
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    return FirebaseService.run(() async {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    });
  }

  // ─── Password Reset ───────────────────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    return FirebaseService.run(() async {
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  // ─── Delete Account ───────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    return FirebaseService.run(() async {
      final user = _auth.currentUser;
      if (user == null) return;

      // Delete Firestore data first (best-effort — anonymous users have no doc)
      try {
        await _firestore.collection('users').doc(user.uid).delete();
      } catch (_) {}

      // Delete auth account
      await user.delete();
    });
  }

  // ─── Update User Fields ───────────────────────────────────────────────────

  Future<void> updateUserField(Map<String, dynamic> fields) async {
    return FirebaseService.run(() async {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await _firestore.collection('users').doc(uid).update(fields);
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Public wrapper – fetches or creates the Firestore user document.
  /// Used by [AuthProvider] when restoring a persisted Firebase session.
  Future<UserModel> loadOrCreateUserProfile(User user) =>
      FirebaseService.run(() => _fetchOrCreateUserDoc(user));

  /// Fetches the Firestore user document. If it doesn't exist (e.g. first
  /// Google sign-in), creates it from the [User] profile data.
  Future<UserModel> _fetchOrCreateUserDoc(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      return UserModel.fromFirestore(snapshot.data()!);
    }

    // First-time social sign-in → create document
    final now = Timestamp.now();
    final userData = UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
      language: 'en',
      themeMode: 'light',
      notificationsEnabled: true,
      smsAlertsEnabled: false,
      reminderDaysBefore: 3,
      createdAt: now.toDate(),
    );

    await docRef.set(userData.toFirestore());
    return userData;
  }
}
