// ---
// STATE MANAGEMENT: auth_provider.dart
// ---
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list_app/features/auth/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // State variables
  User? _user;
  bool _isLoading = true; // Starts as true while we check the initial session
  String? _errorMessage;

  // Getters for the UI to consume
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // CONSTRUCTOR
  AuthProvider() {
    _initializeAuthListener();
  }

  // ---
  // SESSION LISTENER
  // ---
  // We subscribe to the AuthRepository's stream. Whenever the user logs in
  // or out, this listener triggers, updates the local state, and notifies the UI.
  void _initializeAuthListener() {
    _authRepository.authStateChanges.listen((User? firebaseUser) {
      _user = firebaseUser;
      _isLoading = false;
      notifyListeners();
    });
  }

  // ---
  // EXPOSED METHODS FOR THE UI
  // ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true; // Success
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An unknown authentication error occurred.';
      _setLoading(false);
      return false; // Failure
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

  // Helper method to manage loading state and trigger UI rebuilds
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clears any previous error messages (useful when switching between Login and Sign Up)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
