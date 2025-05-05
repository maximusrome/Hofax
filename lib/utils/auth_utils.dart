import 'package:flutter/material.dart';
import '../pages/login_register_page.dart';

void showSignInPrompt(BuildContext context, {String? message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message ?? 'You must be signed in to perform this action'),
      action: SnackBarAction(
        label: 'Sign In',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.purple,
    ),
  );
}
// Performance improvements
// Better error handling
// Code optimization
