import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/movie.dart';

abstract class WatchlistRepository {
  // Get all watchlist items
  Future<Either<Failure, List<Movie>>> getWatchlist();

  // Add item to watchlist
  Future<Either<Failure, bool>> addToWatchlist(Movie movie);

  // Remove item from watchlist
  Future<Either<Failure, bool>> removeFromWatchlist(String movieId);

  // Check if item is in watchlist
  Future<Either<Failure, bool>> isInWatchlist(String movieId);

  // Clear watchlist
  Future<Either<Failure, bool>> clearWatchlist();

  // Get watchlist count
  Future<Either<Failure, int>> getWatchlistCount();

  // Update watchlist item (e.g., mark as watched)
  Future<Either<Failure, bool>> updateWatchlistItem(Movie movie);

  // Get watchlist by type (movies or TV shows)
  Future<Either<Failure, List<Movie>>> getWatchlistByType(ContentType type);

  // Get recently added items
  Future<Either<Failure, List<Movie>>> getRecentlyAddedToWatchlist({
    int limit = 10,
  });

  // Sort watchlist
  Future<Either<Failure, List<Movie>>> getSortedWatchlist({
    required String sortBy, // title, date_added, rating, year
    bool ascending = true,
  });

  // Search within watchlist
  Future<Either<Failure, List<Movie>>> searchWatchlist(String query);

  // Export watchlist (for backup)
  Future<Either<Failure, String>> exportWatchlist();

  // Import watchlist (from backup)
  Future<Either<Failure, bool>> importWatchlist(String data);
}