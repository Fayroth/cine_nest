enum ContentType { movie, tvShow }

class Movie {
  final String id;
  final String title;
  final int year;
  final String genre;
  final double rating;
  final ContentType type;
  final String? synopsis;
  final String? posterUrl;
  final String duration;
  final bool isInWatchlist;
  final DateTime? dateAdded;
  final double? userRating;
  final String? review;
  final DateTime? dateRated;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.rating,
    required this.type,
    required this.duration,
    this.synopsis,
    this.posterUrl,
    this.isInWatchlist = false,
    this.dateAdded,
    this.userRating,
    this.review,
    this.dateRated,
  });

  Movie copyWith({
    String? id,
    String? title,
    int? year,
    String? genre,
    double? rating,
    ContentType? type,
    String? synopsis,
    String? posterUrl,
    String? duration,
    bool? isInWatchlist,
    DateTime? dateAdded,
    double? userRating,
    String? review,
    DateTime? dateRated,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      type: type ?? this.type,
      synopsis: synopsis ?? this.synopsis,
      posterUrl: posterUrl ?? this.posterUrl,
      duration: duration ?? this.duration,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      dateAdded: dateAdded ?? this.dateAdded,
      userRating: userRating ?? this.userRating,
      review: review ?? this.review,
      dateRated: dateRated ?? this.dateRated,
    );
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      year: json['year'] ?? 0,
      genre: json['genre'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      type: json['type'] == 'TV Show' ? ContentType.tvShow : ContentType.movie,
      duration: json['duration'] ?? '',
      synopsis: json['synopsis'],
      posterUrl: json['posterUrl'],
      isInWatchlist: json['isInWatchlist'] ?? false,
      dateAdded: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'])
          : null,
      userRating: json['userRating']?.toDouble(),
      review: json['review'],
      dateRated: json['dateRated'] != null
          ? DateTime.parse(json['dateRated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'genre': genre,
      'rating': rating,
      'type': type == ContentType.tvShow ? 'TV Show' : 'Movie',
      'duration': duration,
      'synopsis': synopsis,
      'posterUrl': posterUrl,
      'isInWatchlist': isInWatchlist,
      'dateAdded': dateAdded?.toIso8601String(),
      'userRating': userRating,
      'review': review,
      'dateRated': dateRated?.toIso8601String(),
    };
  }

  String get typeString => type == ContentType.tvShow ? 'TV Show' : 'Movie';

  String getDateAddedString() {
    if (dateAdded == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateAdded!);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }

  String getDateRatedString() {
    if (dateRated == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateRated!);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }
}