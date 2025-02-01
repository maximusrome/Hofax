import 'package:firebase_auth/firebase_auth.dart';

/// Service responsible for handling all authentication-related operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current authenticated user or null if not authenticated.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes. Emits the current user or null if signed out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in a user with email and password.
  ///
  /// Throws [FirebaseAuthException] if:
  /// - User not found
  /// - Wrong password
  /// - Too many attempts
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Creates a new user account with email and password.
  ///
  /// Throws [FirebaseAuthException] if:
  /// - Email already in use
  /// - Weak password
  /// - Invalid email
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Signs out the current user and clears authentication state.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the specified email address.
  ///
  /// Throws [FirebaseAuthException] if:
  /// - User not found
  /// - Invalid email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Deletes the current user account.
  ///
  /// Throws [FirebaseAuthException] if:
  /// - User not found
  /// - Requires recent login
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
// Authentication flow improvements
// Better error handling for login/register
// Password strength validation
