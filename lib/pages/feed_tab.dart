import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/firestore_service.dart';
import '../widgets/rating_card.dart';
import '../auth.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  _FeedTabState createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final FirestoreService _ratingService = FirestoreService();
  final _auth = AuthService();

  Future<void> _handleLikeRating(String ratingId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be signed in to like ratings'),
            backgroundColor: Colors.purple,
          ),
        );
      }
      return;
    }

    try {
      await _ratingService.toggleLikeRating(ratingId, currentUser.uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error liking rating: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Rating>>(
      stream: _ratingService.getFeedRatings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final ratings = snapshot.data ?? [];
        if (ratings.isEmpty) {
          return const Center(child: Text('No ratings in your feed yet'));
        }

        final currentUser = _auth.currentUser;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            final rating = ratings[index];
            final isLiked =
                currentUser != null &&
                _ratingService.hasUserLikedRating(rating, currentUser.uid);

            return RatingCard(
              rating: rating,
              showLikeButton: true,
              isLiked: isLiked,
              onLike: () => _handleLikeRating(rating.id),
            );
          },
        );
      },
    );
  }
}
// Feed performance optimization
// Better loading states
// Infinite scroll implementation
