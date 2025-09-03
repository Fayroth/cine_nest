class AppConstants {
  // App Info
  static const String appName = 'CineNest';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int pageSize = 20;
  static const int maxCacheSize = 100;

  // Cache Duration
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const Duration searchCacheDuration = Duration(minutes: 30);

  // Local Storage
  static const String databaseName = 'cinenest_db';
  static const int databaseVersion = 1;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Debounce Duration
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Limits
  static const int maxRecentSearches = 10;
  static const int maxWatchlistItems = 500;
  static const int maxRatings = 1000;
}