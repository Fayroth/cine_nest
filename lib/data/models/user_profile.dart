// lib/data/models/user_profile.dart
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPreferences preferences;
  final UserStats? stats;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.preferences,
    this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'CineNest User',
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as dynamic).toDate()
          : DateTime.now(),
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : UserPreferences(),
      stats: json['stats'] != null
          ? UserStats.fromJson(json['stats'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'preferences': preferences.toJson(),
      if (stats != null) 'stats': stats!.toJson(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}

class UserPreferences {
  final bool isDarkMode;
  final String language;
  final String region;
  final bool adultContent;
  final bool notifications;
  final List<String> favoriteGenres;

  UserPreferences({
    this.isDarkMode = true,
    this.language = 'en-US',
    this.region = 'US',
    this.adultContent = false,
    this.notifications = true,
    this.favoriteGenres = const [],
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['isDarkMode'] ?? true,
      language: json['language'] ?? 'en-US',
      region: json['region'] ?? 'US',
      adultContent: json['adultContent'] ?? false,
      notifications: json['notifications'] ?? true,
      favoriteGenres: json['favoriteGenres'] != null
          ? List<String>.from(json['favoriteGenres'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'region': region,
      'adultContent': adultContent,
      'notifications': notifications,
      'favoriteGenres': favoriteGenres,
    };
  }

  UserPreferences copyWith({
    bool? isDarkMode,
    String? language,
    String? region,
    bool? adultContent,
    bool? notifications,
    List<String>? favoriteGenres,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      region: region ?? this.region,
      adultContent: adultContent ?? this.adultContent,
      notifications: notifications ?? this.notifications,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
    );
  }
}

class UserStats {
  final int watchlistCount;
  final int ratingsCount;
  final int favoritesCount;
  final int moviesWatched;
  final int tvShowsWatched;
  final double averageRating;
  final int totalWatchTime;

  UserStats({
    this.watchlistCount = 0,
    this.ratingsCount = 0,
    this.favoritesCount = 0,
    this.moviesWatched = 0,
    this.tvShowsWatched = 0,
    this.averageRating = 0.0,
    this.totalWatchTime = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      watchlistCount: json['watchlistCount'] ?? 0,
      ratingsCount: json['ratingsCount'] ?? 0,
      favoritesCount: json['favoritesCount'] ?? 0,
      moviesWatched: json['moviesWatched'] ?? 0,
      tvShowsWatched: json['tvShowsWatched'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalWatchTime: json['totalWatchTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watchlistCount': watchlistCount,
      'ratingsCount': ratingsCount,
      'favoritesCount': favoritesCount,
      'moviesWatched': moviesWatched,
      'tvShowsWatched': tvShowsWatched,
      'averageRating': averageRating,
      'totalWatchTime': totalWatchTime,
    };
  }

  UserStats copyWith({
    int? watchlistCount,
    int? ratingsCount,
    int? favoritesCount,
    int? moviesWatched,
    int? tvShowsWatched,
    double? averageRating,
    int? totalWatchTime,
  }) {
    return UserStats(
      watchlistCount: watchlistCount ?? this.watchlistCount,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      moviesWatched: moviesWatched ?? this.moviesWatched,
      tvShowsWatched: tvShowsWatched ?? this.tvShowsWatched,
      averageRating: averageRating ?? this.averageRating,
      totalWatchTime: totalWatchTime ?? this.totalWatchTime,
    );
  }
}