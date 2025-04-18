import 'package:flutter/material.dart';
import '../auth.dart';
import '../pages/account_page.dart';
import '../pages/login_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/info_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final _auth = AuthService();
  CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: const Text('Information'),
                    ),
                    body: const InfoPage(),
                  ),
            ),
          );
        },
      ),
      title: const Text('HoFax', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        StreamBuilder<User?>(
          stream: _auth.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountPage()),
                  );
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
// Performance improvements
// Better error handling
// Code optimization
