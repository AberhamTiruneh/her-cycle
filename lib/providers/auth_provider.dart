import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  // ─── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool _isFirstLaunch = true;
  bool _authStreamReady = false;
  bool _isGuestMode = false;
  String? _errorMessage;
  UserModel? _currentUser;
  StreamSubscription<User?>? _authSub;

  // ─── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get authStreamReady => _authStreamReady;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAnonymous =>
      FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  // ─── Initialization ────────────────────────────────────────────────────────

  /// Called once from main(). Listens to Firebase auth state changes and
  /// handles first-launch detection.
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Only treat as first launch if the key has never been written.
    // The onboarding screen writes 'first_launch = false' when the user
    // completes onboarding, so we must NOT write it here prematurely.
    final isFirstTime = prefs.getBool('first_launch') ?? true;
    _isFirstLaunch = isFirstTime;

    // Subscribe to Firebase auth stream
    _authSub = AuthService.instance.authStateChanges.listen((user) async {
      if (user != null) {
        // Anonymous users don't have a Firestore profile — use an in-memory one.
        if (user.isAnonymous) {
          if (_currentUser?.uid != user.uid) {
            _currentUser = UserModel(
              uid: user.uid,
              name: 'Guest',
              email: '',
              phoneNumber: '',
              createdAt: DateTime.now(),
            );
          }
          _authStreamReady = true;
          notifyListeners();
          return;
        }

        // Immediately populate _currentUser with Firebase Auth data so that
        // isAuthenticated becomes true before the slower Firestore call below.
        // This prevents the splash screen from falling through to /login while
        // the Firestore profile is still loading.
        if (_currentUser?.uid != user.uid) {
          _currentUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phoneNumber: user.phoneNumber ?? '',
            createdAt: DateTime.now(),
          );
        }
        _authStreamReady = true;
        notifyListeners();
        try {
          // Fetch (or create) the full Firestore profile in the background.
          _currentUser =
              await AuthService.instance.loadOrCreateUserProfile(user);
        } catch (_) {
          // Keep the temporary profile set above — user can still access the app.
        }
      } else {
        // Don't wipe a local guest session — it has no Firebase user behind it.
        if (!_isGuestMode) {
          _currentUser = null;
        }
        _authStreamReady = true;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() => _setError(null);

  // ─── Guest Sign-In ─────────────────────────────────────────────────────────────

  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _setError(null);
    try {
      // Try Firebase anonymous auth first.
      _currentUser = await AuthService.instance.signInAnonymously();
      notifyListeners();
      return true;
    } on FirebaseServiceException {
      // Firebase anonymous auth is disabled or unavailable — fall back to a
      // fully local guest session so the user can still explore the app.
      _isGuestMode = true;
      _currentUser = UserModel(
        uid: 'guest_local',
        name: 'Guest',
        email: '',
        phoneNumber: '',
        createdAt: DateTime.now(),
      );
      _authStreamReady = true;
      notifyListeners();
      return true;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Sign Up ───────────────────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await AuthService.instance.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );
      notifyListeners();
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Sign In ───────────────────────────────────────────────────────────────

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Google Sign-In ────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await AuthService.instance.signInWithGoogle();
      notifyListeners();
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _setLoading(true);
    _isGuestMode = false;
    try {
      await AuthService.instance.signOut();
      _currentUser = null;
      notifyListeners();
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // ─── Password Reset ────────────────────────────────────────────────────────

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await AuthService.instance.resetPassword(email);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Toggle Notifications ──────────────────────────────────────────────────

  Future<void> toggleNotifications(bool enabled) async {
    if (_currentUser == null) return;
    _currentUser = UserModel(
      uid: _currentUser!.uid,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phoneNumber: _currentUser!.phoneNumber,
      dateOfBirth: _currentUser!.dateOfBirth,
      language: _currentUser!.language,
      themeMode: _currentUser!.themeMode,
      notificationsEnabled: enabled,
      smsAlertsEnabled: _currentUser!.smsAlertsEnabled,
      reminderDaysBefore: _currentUser!.reminderDaysBefore,
      createdAt: _currentUser!.createdAt,
    );
    notifyListeners();
    try {
      await AuthService.instance
          .updateUserField({'notificationsEnabled': enabled});
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
    }
  }

  // ─── Delete Account ────────────────────────────────────────────────────────

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);
    try {
      await AuthService.instance.deleteAccount();
      _currentUser = null;
      notifyListeners();
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
