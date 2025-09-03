import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/genre.dart';

abstract class GenreRepository {
  // Get all movie genres
  Future<Either<Failure, List<Genre>>> getMovieGenres();

  // Get all TV show genres
  Future<Either<Failure, List<Genre>>> getTVGenres();

  // Get genre by ID
  Future<Either<Failure, Genre>> getGenreById(String genreId);

  // Cache genres locally
  Future<Either<Failure, bool>> cacheGenres(List<Genre> genres);

  // Get cached genres
  Future<Either<Failure, List<Genre>>> getCachedGenres();
}