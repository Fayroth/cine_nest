import '../models/movie.dart';
import '../models/rating.dart';
import '../models/genre.dart';

abstract class LocalDataSource {
  // Watchlist operations
  Future<List<Movie>> getWatchlist();
  Future<bool> addToWatchlist(Movie movie);
  Future<bool> removeFromWatchlist(String movieId);
  Future<bool> isInWatchlist(String movieId);
  Future<bool> clearWatchlist();
  Future<bool> updateWatchlistItem(Movie movie);

  // Rating operations
  Future<List<Movie>> getRatedItems();
  Future<bool> addOrUpdateRating(String movieId, double rating, String? review);
  Future<bool> removeRating(String movieId);
  Future<Rating?> getRating(String movieId);
  Future<bool> updateReview(String movieId, String review);

  // Cache operations
  Future<bool> cacheMovies(List<Movie> movies, String key);
  Future<List<Movie>?> getCachedMovies(String key);
  Future<bool> clearCache();
  Future<bool> isCacheValid(String key);

  // Genre operations
  Future<bool> cacheGenres(List<Genre> genres);
  Future<List<Genre>?> getCachedGenres();

  // Recent searches
  Future<bool> addRecentSearch(String query);
  Future<List<String>> getRecentSearches();
  Future<bool> clearRecentSearches();

  // Preferences
  Future<bool> savePreference(String key, dynamic value);
  Future<T?> getPreference<T>(String key);
  Future<bool> clearPreferences();
}