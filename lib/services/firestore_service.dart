import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/rating_model.dart';
import '../shared/utils/error_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Types of batch operations that can be performed.
enum BatchOperationType { update, delete }

/// Represents a single operation in a batch update.
class BatchOperation {
  final String path;
  final Map<String, dynamic>? data;
  final BatchOperationType type;

  /// Creates an update operation.
  BatchOperation.update(this.path, this.data)
    : type = BatchOperationType.update,
      assert(data != null);

  /// Creates a delete operation.
  BatchOperation.delete(this.path)
    : data = null,
      type = BatchOperationType.delete;

  /// Applies this operation to a WriteBatch.
  void applyTo(WriteBatch batch) {
    final docRef = FirebaseFirestore.instance.doc(path);
    switch (type) {
      case BatchOperationType.update:
        batch.update(docRef, data!);
      case BatchOperationType.delete:
        batch.delete(docRef);
    }
  }
}

/// Service for interacting with Firestore database.
class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Cache for user documents to reduce database reads.
  final Map<String, DocumentSnapshot> _userCache = {};

  /// Creates a new FirestoreService instance.
  FirestoreService([FirebaseFirestore? firestore, FirebaseAuth? auth])
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Gets a user document by ID, using cache when available.
  Future<DocumentSnapshot> getUserDoc(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final doc =
          await _firestore.collection(CollectionNames.users).doc(userId).get();
      _userCache[userId] = doc;
      return doc;
    } catch (e) {
      throw AppError('Failed to get user document', originalError: e);
    }
  }

  /// Stream of user document updates.
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection(CollectionNames.users).doc(userId).snapshots();
  }

  /// Stream of ratings given by a user.
  Stream<List<Rating>> getRatingsForUser(String userId) {
    return _firestore
        .collection(CollectionNames.ratings)
        .where('raterId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(PaginationConstants.maxRatingsToShow)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Rating.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// Stream of ratings received by a user.
  Stream<List<Rating>> getRatingsReceivedByUser(String userId) {
    return _firestore
        .collection(CollectionNames.ratings)
        .where('ratedUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(PaginationConstants.maxRatingsToShow)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Rating.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  /// Performs multiple operations in a single atomic batch.
  Future<void> batchUpdate(List<BatchOperation> operations) async {
    if (operations.isEmpty) return;

    try {
      final batch = _firestore.batch();
      for (final op in operations) {
        op.applyTo(batch);
      }
      await batch.commit();
    } catch (e) {
      throw AppError('Failed to perform batch update', originalError: e);
    }
  }

  /// Deletes a rating and updates related user statistics.
  Future<void> deleteRating(
    String ratingId,
    String raterId,
    String ratedUserId,
  ) async {
    try {
      await batchUpdate([
        BatchOperation.delete('${CollectionNames.ratings}/$ratingId'),
        BatchOperation.update('${CollectionNames.users}/$raterId', {
          'ratingsGiven': FieldValue.increment(-1),
        }),
        BatchOperation.update('${CollectionNames.users}/$ratedUserId', {
          'ratingsReceived': FieldValue.increment(-1),
        }),
      ]);

      // Clear cache entries as they're now stale
      _userCache.remove(raterId);
      _userCache.remove(ratedUserId);
    } catch (e) {
      throw AppError('Failed to delete rating', originalError: e);
    }
  }

  /// Updates an existing rating.
  Future<void> updateRating(String ratingId, Rating rating) async {
    try {
      print('Updating rating with ID: $ratingId');
      final ratingRef = _firestore
          .collection(CollectionNames.ratings)
          .doc(ratingId);
      final userRef = _firestore
          .collection(CollectionNames.users)
          .doc(rating.ratedUserId);

      await _firestore.runTransaction((transaction) async {
        // Get the current rating
        final ratingDoc = await transaction.get(ratingRef);
        if (!ratingDoc.exists) {
          throw AppError('Rating document not found. ID: $ratingId');
        }

        // Get the user document to update average
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          throw AppError('User document not found. ID: ${rating.ratedUserId}');
        }

        // Get the old rating value
        final oldRating = Rating.fromFirestore(ratingDoc.data()!, ratingDoc.id);
        if (oldRating.raterId != rating.raterId) {
          throw AppError(
            'Cannot update rating: You are not the original rater',
          );
        }

        final currentRatingsReceived = userDoc.data()?['ratingsReceived'] ?? 0;
        final currentAverageRating = userDoc.data()?['averageRating'] ?? 0.0;

        print(
          'Old rating: ${oldRating.overallRating}, New rating: ${rating.overallRating}',
        );

        // Remove old rating from average and add new rating
        final newAverageRating =
            ((currentAverageRating * currentRatingsReceived) -
                oldRating.overallRating +
                rating.overallRating) /
            currentRatingsReceived;

        print(
          'Updating average rating from $currentAverageRating to $newAverageRating',
        );

        // Remove the id field from the data before updating
        final updateData = rating.toFirestore();
        updateData.remove('id');

        // Update both the rating and the user's average
        transaction.update(ratingRef, updateData);
        transaction.update(userRef, {'averageRating': newAverageRating});
      });
      print('Rating update completed successfully');
    } catch (e) {
      print('Error updating rating: $e');
      if (e is AppError) {
        throw e;
      }
      throw AppError(
        'Failed to update rating: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Clears the user cache.
  void clearCache() {
    _userCache.clear();
  }

  /// Get a user's name by their ID
  Future<String> getUserName(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return 'Unknown';
      }
      return (doc.data()?['name'] as String?) ?? 'Unknown';
    } catch (e) {
      print('Error getting user name: $e');
      return 'Unknown';
    }
  }

  /// Get ratings for the user's feed (ratings from people they follow)
  Stream<List<Rating>> getFeedRatings() async* {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      yield [];
      return;
    }

    try {
      // Get the user's document to get their following list
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final following = List<String>.from(userDoc.data()?['following'] ?? []);

      if (following.isEmpty) {
        yield [];
        return;
      }

      yield* _firestore
          .collection('ratings')
          .where('ratedUserId', whereIn: following)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return Rating.fromFirestore(doc.data(), doc.id);
            }).toList();
          });
    } catch (e) {
      print('Error getting feed ratings: $e');
      yield [];
    }
  }

  /// Toggle like status for a rating
  Future<void> toggleLikeRating(String ratingId, String userId) async {
    try {
      final ratingRef = _firestore.collection('ratings').doc(ratingId);

      return _firestore.runTransaction((transaction) async {
        final ratingDoc = await transaction.get(ratingRef);

        if (!ratingDoc.exists) {
          throw AppError('Rating not found');
        }

        final rating = Rating.fromFirestore(ratingDoc.data()!, ratingDoc.id);

        // Prevent users from liking their own ratings
        if (rating.raterId == userId) {
          throw AppError('You cannot like your own rating');
        }

        final likedByUsers = List<String>.from(rating.likedByUsers);
        final raterRef = _firestore.collection('users').doc(rating.raterId);

        // Verify rater still exists
        final raterDoc = await transaction.get(raterRef);
        if (!raterDoc.exists) {
          throw AppError('Rating author no longer exists');
        }

        if (likedByUsers.contains(userId)) {
          // Unlike
          likedByUsers.remove(userId);
          transaction.update(ratingRef, {
            'likedByUsers': likedByUsers,
            'likesCount': FieldValue.increment(-1),
          });
          transaction.update(raterRef, {
            'totalLikesReceived': FieldValue.increment(-1),
          });
        } else {
          // Like
          likedByUsers.add(userId);
          transaction.update(ratingRef, {
            'likedByUsers': likedByUsers,
            'likesCount': FieldValue.increment(1),
          });
          transaction.update(raterRef, {
            'totalLikesReceived': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      if (e is AppError) {
        throw e;
      }
      throw AppError('Failed to update like status', originalError: e);
    }
  }

  /// Check if a user has liked a rating
  bool hasUserLikedRating(Rating rating, String userId) {
    return rating.likedByUsers.contains(userId);
  }

  /// Check if a rating already exists from rater to rated user
  Future<bool> hasExistingRating(String raterId, String ratedUserId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(CollectionNames.ratings)
              .where('raterId', isEqualTo: raterId)
              .where('ratedUserId', isEqualTo: ratedUserId)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking existing rating: $e');
      throw AppError('Failed to check existing rating', originalError: e);
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
        throw AppError('You have already rated this user');
      }

      // Create the rating document
      final ratingRef = _firestore.collection(CollectionNames.ratings).doc();
      final ratingWithId = rating.copyWith(id: ratingRef.id);

      await _firestore.runTransaction((transaction) async {
        // Get the user document to update their stats
        final userRef = _firestore
            .collection(CollectionNames.users)
            .doc(rating.ratedUserId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw AppError('User not found');
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
        final raterRef = _firestore
            .collection(CollectionNames.users)
            .doc(rating.raterId);
        transaction.update(raterRef, {'ratingsGiven': FieldValue.increment(1)});
      });
    } catch (e) {
      throw AppError(
        e is AppError ? e.message : 'Failed to submit rating',
        originalError: e is AppError ? e.originalError : e,
      );
    }
  }
}
