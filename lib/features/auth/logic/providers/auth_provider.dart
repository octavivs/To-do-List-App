// ---
// STATE MANAGEMENT: auth_provider.dart
// ---
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list_app/features/auth/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? _user;
  // NEW: Dedicated state for app startup
  bool _isCheckingSession = true;
  // EXISTING: Dedicated state for form buttons
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isCheckingSession => _isCheckingSession; // <-- Updated getter
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    _authRepository.authStateChanges.listen((User? firebaseUser) {
      _user = firebaseUser;
      // We only stop checking the session once Firebase responds
      _isCheckingSession = false;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An unknown authentication error occurred.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Failed to create an account.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authRepository.signOut();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
