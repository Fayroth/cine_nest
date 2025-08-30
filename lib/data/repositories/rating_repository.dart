import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/movie.dart';
import '../models/rating.dart';

abstract class RatingRepository {
  // Get all rated items
  Future<Either<Failure, List<Movie>>> getRatedItems();

  // Add or update rating
  Future<Either<Failure, bool>> rateItem({
    required String movieId,
    required double rating,
    String? review,
  });

  // Remove rating
  Future<Either<Failure, bool>> removeRating(String movieId);

  // Get rating for specific item
  Future<Either<Failure, Rating?>> getRating(String movieId);

  // Update review
  Future<Either<Failure, bool>> updateReview({
    required String movieId,
    required String review,
  });

  // Get rated items by rating range
  Future<Either<Failure, List<Movie>>> getRatedItemsByRange({
    required double minRating,
    required double maxRating,
  });

  // Get perfect scores (10/10)
  Future<Either<Failure, List<Movie>>> getPerfectScores();

  // Get ratings count
  Future<Either<Failure, int>> getRatingsCount();

  // Get average rating
  Future<Either<Failure, double>> getAverageRating();

  // Get ratings by type
  Future<Either<Failure, List<Movie>>> getRatingsByType(ContentType type);

  // Sort ratings
  Future<Either<Failure, List<Movie>>> getSortedRatings({
    required String sortBy, // rating, date_rated, title, year
    bool ascending = true,
  });

  // Get rating statistics
  Future<Either<Failure, Map<String, dynamic>>> getRatingStatistics();

  // Export ratings (for backup)
  Future<Either<Failure, String>> exportRatings();

  // Import ratings (from backup)
  Future<Either<Failure, bool>> importRatings(String data);

  // Get recently rated items
  Future<Either<Failure, List<Movie>>> getRecentlyRated({
    int limit = 10,
  });
}