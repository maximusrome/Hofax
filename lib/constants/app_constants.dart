/// Application-wide constants and configuration values.
class AppConstants {
  // App information
  static const String appName = 'Hofax';
  static const String appVersion = '1.0.0';
  
  // Firebase collection names
  static const String usersCollection = 'users';
  static const String ratingsCollection = 'ratings';
  
  // Pagination limits
  static const int maxRatingsToShow = 20;
  static const int maxUsersToShow = 50;
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Constants for rating categories and their maximum values.
class RatingConstants {
  static const double maxEmotionalIntelligence = 10.0;
  static const double maxValues = 10.0;
  static const double maxIntelligence = 10.0;
  static const double maxVibe = 10.0;
  static const double maxCommitment = 10.0;
  static const double maxStability = 10.0;
  static const double maxAttractiveness = 10.0;
}

/// Collection names for Firestore.
class CollectionNames {
  static const String users = 'users';
  static const String ratings = 'ratings';
}

/// Pagination constants.
class PaginationConstants {
  static const int maxRatingsToShow = 20;
  static const int maxUsersToShow = 50;
}
// Performance improvements
// Better caching
// Memory optimization
