import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/movie.dart';

abstract class MovieRepository {
  // Get trending movies/shows
  Future<Either<Failure, List<Movie>>> getTrending({
    int page = 1,
    String timeWindow = 'week', // day or week
  });

  // Get popular movies
  Future<Either<Failure, List<Movie>>> getPopularMovies({
    int page = 1,
  });

  // Get popular TV shows
  Future<Either<Failure, List<Movie>>> getPopularTVShows({
    int page = 1,
  });

  // Get top rated movies
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({
    int page = 1,
  });

  // Get top rated TV shows
  Future<Either<Failure, List<Movie>>> getTopRatedTVShows({
    int page = 1,
  });

  // Search movies and TV shows
  Future<Either<Failure, List<Movie>>> searchMulti({
    required String query,
    int page = 1,
  });

  // Get movie details
  Future<Either<Failure, Movie>> getMovieDetails({
    required String movieId,
  });

  // Get TV show details
  Future<Either<Failure, Movie>> getTVShowDetails({
    required String tvShowId,
  });

  // Get movies by genre
  Future<Either<Failure, List<Movie>>> getMoviesByGenre({
    required String genreId,
    int page = 1,
  });

  // Get TV shows by genre
  Future<Either<Failure, List<Movie>>> getTVShowsByGenre({
    required String genreId,
    int page = 1,
  });

  // Get similar movies
  Future<Either<Failure, List<Movie>>> getSimilarMovies({
    required String movieId,
    int page = 1,
  });

  // Get similar TV shows
  Future<Either<Failure, List<Movie>>> getSimilarTVShows({
    required String tvShowId,
    int page = 1,
  });

  // Get movie recommendations
  Future<Either<Failure, List<Movie>>> getMovieRecommendations({
    required String movieId,
    int page = 1,
  });

  // Get TV show recommendations
  Future<Either<Failure, List<Movie>>> getTVShowRecommendations({
    required String tvShowId,
    int page = 1,
  });
}