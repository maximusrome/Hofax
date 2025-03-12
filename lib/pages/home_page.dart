import 'package:firebase_auth/firebase_auth.dart';
import 'package:hofax/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final _auth = AuthService();
  HomePage({Key? key}) : super(key: key);

  User? get user => _auth.currentUser;

  Future<String?> _getUserName() async {
    if (user == null) return null;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
    return doc.data()?['name'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<String?>(
        future: _getUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome ${snapshot.data ?? 'User'}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(user?.email ?? 'No email'),
            ],
          );
        },
      ),
    );
  }
}
// Home page improvements
// Better navigation
// User experience enhancements
