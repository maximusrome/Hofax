import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import '../widgets/rating_card.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/rating_model.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;
  final String userName;
  final _firestoreService = FirestoreService();
  final _auth = AuthService();

  UserProfilePage({Key? key, required this.userId, required this.userName})
    : super(key: key);

  Future<Map<String, dynamic>> _getUserData() async {
    // First check if current user is following this profile
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Not authenticated');
    }

    final currentUserDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

    final following =
        (currentUserDoc.data()?['following'] as List?)?.contains(userId) ??
        false;

    // If not following and not viewing own profile, deny access
    if (!following && currentUser.uid != userId) {
      throw Exception('Must follow user to view profile');
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    final ratingsSnapshot =
        await FirebaseFirestore.instance
            .collection('ratings')
            .where('ratedUserId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();

    return {
      'user': userDoc.data()!,
      'ratings':
          ratingsSnapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
    };
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildUserInfoCard(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              userData['name'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  'Rating',
                  userData['averageRating']?.toStringAsFixed(1) ?? '0.0',
                ),
                _buildStat(
                  'Ratings',
                  userData['ratingsReceived']?.toString() ?? '0',
                ),
                _buildStat(
                  'Likes',
                  userData['totalLikesReceived']?.toString() ?? '0',
                ),
                _buildStat(
                  'Followers',
                  userData['followers']?.toString() ?? '0',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final userData = snapshot.data!['user'] as Map<String, dynamic>;
          final ratings = snapshot.data!['ratings'] as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoCard(userData, context),
                const SizedBox(height: 24.0),
                Text(
                  'Ratings Received',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ratings.length,
                  itemBuilder:
                      (context, index) => RatingCard(
                        rating: Rating.fromFirestore(
                          ratings[index] as Map<String, dynamic>,
                          (ratings[index] as Map<String, dynamic>)['id']
                              as String,
                        ),
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
