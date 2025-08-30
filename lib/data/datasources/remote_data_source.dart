import '../models/movie.dart';
import '../models/genre.dart';

abstract class RemoteDataSource {
  // Movies & TV Shows
  Future<List<Movie>> getTrending({int page = 1, String timeWindow = 'week'});
  Future<List<Movie>> getPopularMovies({int page = 1});
  Future<List<Movie>> getPopularTVShows({int page = 1});
  Future<List<Movie>> getTopRatedMovies({int page = 1});
  Future<List<Movie>> getTopRatedTVShows({int page = 1});
  Future<List<Movie>> searchMulti({required String query, int page = 1});
  Future<Movie> getMovieDetails({required String movieId});
  Future<Movie> getTVShowDetails({required String tvShowId});
  Future<List<Movie>> getMoviesByGenre({required String genreId, int page = 1});
  Future<List<Movie>> getTVShowsByGenre({required String genreId, int page = 1});
  Future<List<Movie>> getSimilarMovies({required String movieId, int page = 1});
  Future<List<Movie>> getSimilarTVShows({required String tvShowId, int page = 1});
  Future<List<Movie>> getMovieRecommendations({required String movieId, int page = 1});
  Future<List<Movie>> getTVShowRecommendations({required String tvShowId, int page = 1});

  // Genres
  Future<List<Genre>> getMovieGenres();
  Future<List<Genre>> getTVGenres();
}