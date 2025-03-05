import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();

    return snapshot.docs
        .map(
          (doc) => {
            'id': doc.id,
            'name': doc.data()['name'],
            'email': doc.data()['email'],
          },
        )
        .toList();
  }

  /// Check if a rating already exists from rater to rated user
  Future<bool> hasExistingRating(String raterId, String ratedUserId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('ratings')
              .where('raterId', isEqualTo: raterId)
              .where('ratedUserId', isEqualTo: ratedUserId)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing rating: $e');
      throw Exception('Failed to check existing rating');
    }
  }

  /// Submit a new rating, ensuring only one rating per user
  Future<void> submitRating(Rating rating) async {
    try {
      // Check if rating already exists
      final hasRating = await hasExistingRating(
        rating.raterId,
        rating.ratedUserId,
      );
      if (hasRating) {
        throw Exception('You have already rated this user');
      }

      // Create the rating document
      final ratingRef = _firestore.collection('ratings').doc();
      final ratingWithId = rating.copyWith(id: ratingRef.id);

      await _firestore.runTransaction((transaction) async {
        // Get the user document to update their stats
        final userRef = _firestore.collection('users').doc(rating.ratedUserId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final currentRatingsReceived = userDoc.data()?['ratingsReceived'] ?? 0;
        final currentAverageRating = userDoc.data()?['averageRating'] ?? 0.0;

        // Calculate new average rating
        final newAverageRating =
            ((currentAverageRating * currentRatingsReceived) +
                rating.overallRating) /
            (currentRatingsReceived + 1);

        // Update both the rating and user documents
        transaction.set(ratingRef, ratingWithId.toFirestore());
        transaction.update(userRef, {
          'ratingsReceived': FieldValue.increment(1),
          'averageRating': newAverageRating,
        });

        // Update rater's stats
        final raterRef = _firestore.collection('users').doc(rating.raterId);
        transaction.update(raterRef, {'ratingsGiven': FieldValue.increment(1)});
      });
    } catch (e) {
      throw Exception(
        e is Exception ? e.toString() : 'Failed to submit rating',
      );
    }
  }

  /// Toggles the like status of a rating for a user
  Future<void> toggleLikeRating(String ratingId, String userId) async {
    final ratingRef = _firestore.collection('ratings').doc(ratingId);

    return _firestore.runTransaction((transaction) async {
      final ratingDoc = await transaction.get(ratingRef);

      if (!ratingDoc.exists) {
        throw Exception('Rating not found');
      }

      final rating = Rating.fromFirestore(ratingDoc.data()!);
      final likedByUsers = List<String>.from(rating.likedByUsers);

      if (likedByUsers.contains(userId)) {
        // Unlike
        likedByUsers.remove(userId);
        transaction.update(ratingRef, {
          'likedByUsers': likedByUsers,
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Like
        likedByUsers.add(userId);
        transaction.update(ratingRef, {
          'likedByUsers': likedByUsers,
          'likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  /// Check if a user has liked a rating
  bool hasUserLikedRating(Rating rating, String userId) {
    return rating.likedByUsers.contains(userId);
  }
}
// Performance optimizations
// Better caching strategy
// Memory management
