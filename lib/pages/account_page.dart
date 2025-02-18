import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import '../services/firestore_service.dart';
import 'manage_ratings_page.dart';
import 'received_ratings_page.dart';

class AccountPage extends StatelessWidget {
  final _auth = AuthService();
  final _firestoreService = FirestoreService();
  AccountPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      return doc.data();
    }
    return null;
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    // Clear cached data
    _firestoreService.clearCache();
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await _signOut();
    if (context.mounted) {
      // Navigate to root with explore tab index
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/', (route) => false, arguments: 2);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Delete the authentication user first
      await user.delete();

      // If auth deletion successful, delete the user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Clear any cached data
      _firestoreService.clearCache();

      // Use the exact same navigation as sign out
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/', (route) => false, arguments: 2);
      }
    } catch (e) {
      print('Error in deletion process: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please sign out and sign in again before deleting your account',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account'),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(_auth.currentUser?.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        userData['name'] ?? 'N/A',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData['email'] ?? 'N/A',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Statistics Section
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          'Average Rating',
                          '${(userData['averageRating'] ?? 0.0).toStringAsFixed(1)}',
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Ratings Given',
                          '${userData['ratingsGiven'] ?? 0}',
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Ratings Received',
                          '${userData['ratingsReceived'] ?? 0}',
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Total Likes',
                          '${userData['totalLikesReceived'] ?? 0}',
                        ),
                        const Divider(height: 24),
                        _buildStatRow(
                          'Followers',
                          '${userData['followers'] ?? 0}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions Section
                Card(
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Ratings Given'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ManageRatingsPage(
                                    userId: _auth.currentUser!.uid,
                                  ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Ratings Received'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ReceivedRatingsPage(
                                    userId: _auth.currentUser!.uid,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Actions Section
                Card(
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Sign Out'),
                        onTap: () => _handleSignOut(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap:
                            () => showDialog(
                              context: context,
                              builder:
                                  (dialogContext) => AlertDialog(
                                    title: const Text('Delete Account'),
                                    content: const Text(
                                      'Are you sure you want to delete your account? '
                                      'This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(dialogContext),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // First close the dialog
                                          Navigator.pop(dialogContext);
                                          // Then delete the account and navigate
                                          await _deleteAccount(context);
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
// Account management improvements
// Better settings organization
// Privacy controls
