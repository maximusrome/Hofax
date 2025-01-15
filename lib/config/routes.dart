import 'package:flutter/material.dart';
import '../pages/main_screen.dart';
import '../pages/login_register_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String account = '/account';
  static const String ratingsGiven = '/ratings/given';
  static const String ratingsReceived = '/ratings/received';
  static const String editRating = '/ratings/edit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      // Add more routes
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('Route ${settings.name} not found')),
              ),
        );
    }
  }
}
