import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/rating_card.dart';
import '../services/firestore_service.dart';
import '../models/rating_model.dart';
import '../constants/app_constants.dart';
import '../pages/edit_rating_page.dart';
import '../auth.dart';

class ManageRatingsPage extends StatelessWidget {
  final String userId;
  final _firestoreService = FirestoreService();

  ManageRatingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings Given'),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<List<Rating>>(
        stream: _firestoreService.getRatingsForUser(userId),
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

              return RatingCard(
                rating: rating,
                onDelete:
                    () => _showDeleteConfirmation(
                      context,
                      rating.id,
                      rating.toFirestore(),
                    ),
                onEdit: () async {
                  // Get the rated user's name
                  final userDoc =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(rating.ratedUserId)
                          .get();
                  final userData = userDoc.data() as Map<String, dynamic>?;
                  final userName = userData?['name'] ?? 'Unknown';

                  if (context.mounted) {
                    print(
                      'Editing rating with ID: ${rating.id}',
                    ); // Debug print
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditRatingPage(
                              ratingId: rating.id,
                              ratingData: rating.toFirestore(),
                              ratedUserName: userName,
                            ),
                      ),
                    );
                  }
                },
              );
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
          Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16.0),
          Text(
            'No ratings given yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    String ratingId,
    Map<String, dynamic> ratingData,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Rating?'),
          content: const Text('Are you sure you want to delete this rating?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await _firestoreService.deleteRating(
                    ratingId,
                    userId,
                    ratingData['ratedUserId'],
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error deleting rating'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
// Rating management improvements
// Better user interface
// Performance optimization
