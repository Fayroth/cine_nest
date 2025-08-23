class Rating {
  final String movieId;
  final double rating;
  final String? review;
  final DateTime dateRated;

  Rating({
    required this.movieId,
    required this.rating,
    this.review,
    required this.dateRated,
  });

  Rating copyWith({
    String? movieId,
    double? rating,
    String? review,
    DateTime? dateRated,
  }) {
    return Rating(
      movieId: movieId ?? this.movieId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      dateRated: dateRated ?? this.dateRated,
    );
  }
}