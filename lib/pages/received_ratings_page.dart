import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/rating_card.dart';
import '../services/firestore_service.dart';
import '../models/rating_model.dart';

class ReceivedRatingsPage extends StatelessWidget {
  final String userId;
  final _firestoreService = FirestoreService();

  ReceivedRatingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings Received'),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<List<Rating>>(
        stream: _firestoreService.getRatingsReceivedByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final rating = snapshot.data![index];
              final ratingData = rating.toFirestore();

              return RatingCard(rating: rating);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16.0),
          Text(
            'No ratings received yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
