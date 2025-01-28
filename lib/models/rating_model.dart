import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

/// Represents a rating given by one user to another.
class Rating {
  final String id;
  final String raterId;
  final String ratedUserId;
  final double emotionalIntelligence;
  final double values;
  final double intelligence;
  final double vibe;
  final double commitment;
  final double stability;
  final double attractiveness;
  final DateTime timestamp;
  final int likesCount;
  final List<String> likedByUsers;

  Rating._({
    required this.id,
    required this.raterId,
    required this.ratedUserId,
    required this.emotionalIntelligence,
    required this.values,
    required this.intelligence,
    required this.vibe,
    required this.commitment,
    required this.stability,
    required this.attractiveness,
    required this.timestamp,
    this.likesCount = 0,
    this.likedByUsers = const [],
  });

  /// Creates a new Rating instance with validation.
  factory Rating({
    String? id,
    required String raterId,
    required String ratedUserId,
    required double emotionalIntelligence,
    required double values,
    required double intelligence,
    required double vibe,
    required double commitment,
    required double stability,
    required double attractiveness,
    DateTime? timestamp,
    int likesCount = 0,
    List<String> likedByUsers = const [],
  }) {
    // Validate rating values
    assert(
      emotionalIntelligence >= 0 &&
          emotionalIntelligence <= RatingConstants.maxEmotionalIntelligence,
    );
    assert(values >= 0 && values <= RatingConstants.maxValues);
    assert(
      intelligence >= 0 && intelligence <= RatingConstants.maxIntelligence,
    );
    assert(vibe >= 0 && vibe <= RatingConstants.maxVibe);
    assert(commitment >= 0 && commitment <= RatingConstants.maxCommitment);
    assert(stability >= 0 && stability <= RatingConstants.maxStability);
    assert(
      attractiveness >= 0 &&
          attractiveness <= RatingConstants.maxAttractiveness,
    );

    return Rating._(
      id: id ?? '',
      raterId: raterId,
      ratedUserId: ratedUserId,
      emotionalIntelligence: emotionalIntelligence,
      values: values,
      intelligence: intelligence,
      vibe: vibe,
      commitment: commitment,
      stability: stability,
      attractiveness: attractiveness,
      timestamp: timestamp ?? DateTime.now(),
      likesCount: likesCount,
      likedByUsers: likedByUsers,
    );
  }

  /// Creates a Rating instance from Firestore data.
  factory Rating.fromFirestore(Map<String, dynamic> data, [String? id]) {
    return Rating._(
      id: id ?? data['id'] ?? '',
      raterId: data['raterId'] as String,
      ratedUserId: data['ratedUserId'] as String,
      emotionalIntelligence: (data['emotionalIntelligence'] as num).toDouble(),
      values: (data['values'] as num).toDouble(),
      intelligence: (data['intelligence'] as num).toDouble(),
      vibe: (data['vibe'] as num).toDouble(),
      commitment: (data['commitment'] as num).toDouble(),
      stability: (data['stability'] as num).toDouble(),
      attractiveness: (data['attractiveness'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likesCount: data['likesCount'] as int? ?? 0,
      likedByUsers: List<String>.from(data['likedByUsers'] as List? ?? []),
    );
  }

  /// Calculates the overall rating based on all categories.
  double get overallRating {
    return emotionalIntelligence +
        values +
        intelligence +
        vibe +
        commitment +
        stability +
        attractiveness;
  }

  /// Converts the rating to a map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'raterId': raterId,
      'ratedUserId': ratedUserId,
      'emotionalIntelligence': emotionalIntelligence,
      'values': values,
      'intelligence': intelligence,
      'vibe': vibe,
      'commitment': commitment,
      'stability': stability,
      'attractiveness': attractiveness,
      'timestamp': Timestamp.fromDate(timestamp),
      'overallRating': overallRating,
      'likesCount': likesCount,
      'likedByUsers': likedByUsers,
    };
  }

  /// Creates a copy of this Rating with the given fields replaced with new values.
  Rating copyWith({
    String? id,
    String? raterId,
    String? ratedUserId,
    double? emotionalIntelligence,
    double? values,
    double? intelligence,
    double? vibe,
    double? commitment,
    double? stability,
    double? attractiveness,
    DateTime? timestamp,
    int? likesCount,
    List<String>? likedByUsers,
  }) {
    return Rating(
      id: id ?? this.id,
      raterId: raterId ?? this.raterId,
      ratedUserId: ratedUserId ?? this.ratedUserId,
      emotionalIntelligence:
          emotionalIntelligence ?? this.emotionalIntelligence,
      values: values ?? this.values,
      intelligence: intelligence ?? this.intelligence,
      vibe: vibe ?? this.vibe,
      commitment: commitment ?? this.commitment,
      stability: stability ?? this.stability,
      attractiveness: attractiveness ?? this.attractiveness,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      likedByUsers: likedByUsers ?? this.likedByUsers,
    );
  }

  @override
  String toString() {
    return 'Rating(raterId: $raterId, ratedUserId: $ratedUserId, '
        'overallRating: ${overallRating.toStringAsFixed(1)})';
  }
}
// Rating validation improvements
// Better error messages for users
// Input sanitization needed
