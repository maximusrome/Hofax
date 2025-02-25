import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      primarySwatch: Colors.purple,
      appBarTheme: const AppBarTheme(elevation: 1, centerTitle: true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: const Size(200, 45)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class AppColors {
  static const MaterialColor primary = Colors.purple;
  static const Color error = Colors.red;
  static const Color success = Colors.green;
  static const Color background = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  // Add more styles
}
// Theme improvements
// Dark mode support
// Better color scheme
