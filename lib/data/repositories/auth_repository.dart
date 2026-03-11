// ---
// REPOSITORY: auth_repository.dart
// ---
import 'package:firebase_auth/firebase_auth.dart';

// OOP CONCEPT: SINGLE RESPONSIBILITY PRINCIPLE (SRP)
// This repository has exactly one job: managing user authentication via Firebase.
// It hides the complexity of the Firebase SDK from the rest of our application.
class AuthRepository {
  // We instantiate a private instance of the FirebaseAuth service.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ---
  // AUTH STATE STREAM
  // ---
  // FLUTTER CONCEPT: Streams
  // A Stream is like a pipe that continuously delivers data over time.
  // This specific stream listens for changes in the user's session (e.g., when
  // they log in or log out) and emits the current User object or null.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Retrieves the currently logged-in user synchronously, if any.
  User? get currentUser => _firebaseAuth.currentUser;

  // ---
  // SIGN UP (CREATE ACCOUNT)
  // ---
  // Asynchronous method to register a new user using Email and Password.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // In a production app, we would handle specific Firebase exceptions here
      // (e.g., 'email-already-in-use', 'weak-password') and rethrow custom errors.
      rethrow;
    }
  }

  // ---
  // LOG IN (AUTHENTICATE EXISTING USER)
  // ---
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ---
  // LOG OUT
  // ---
  // Clears the current session from the device and invalidates the token.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
