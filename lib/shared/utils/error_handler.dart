import 'package:firebase_auth/firebase_auth.dart';

class AppError extends Error {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password provided';
        // Add more cases
        default:
          return error.message ?? 'An unknown error occurred';
      }
    }
    return error.toString();
  }
}
// Error handling improvements
// Better user feedback
// Validation enhancements
