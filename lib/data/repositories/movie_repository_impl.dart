import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../models/movie.dart';
import '../datasources/remote_data_source.dart';
import '../datasources/local_data_source.dart';
import 'movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource? localDataSource;
  final NetworkInfo networkInfo;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Movie>>> getTrending({
    int page = 1,
    String timeWindow = 'week',
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final movies = await remoteDataSource.getTrending(
          page: page,
          timeWindow: timeWindow,
        );

        // Optionally cache the results
        // if (localDataSource != null) {
        //   await localDataSource!.cacheMovies(movies, 'trending');
        // }

        return Right(movies);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      // Try to get cached data if available
      // if (localDataSource != null) {
      //   try {
      //     final cachedMovies = await localDataSource!.getCachedMovies('trending');
      //     if (cachedMovies != null) {
      //       return Right(cachedMovies);
      //     }
      //   } catch (e) {
      //     // Fall through to network failure
      //   }
      // }

      return const Left(NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final movies = await remoteDataSource.getPopularMovies(page: page);
        return Right(movies);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularTVShows({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final tvShows = await remoteDataSource.getPopularTVShows(page: page);
        return Right(tvShows);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final movies = await remoteDataSource.getTopRatedMovies(page: page);
        return Right(movies);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedTVShows({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final tvShows = await remoteDataSource.getTopRatedTVShows(page: page);
        return Right(tvShows);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMulti({
    required String query,
    int page = 1,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final results = await remoteDataSource.searchMulti(
          query: query,
          page: page,
        );
        return Right(results);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails({required String movieId}) async {
    if (await networkInfo.isConnected) {
      try {
        final movie = await remoteDataSource.getMovieDetails(movieId: movieId);
        return Right(movie);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ));
    }
  }

  @override
  Future<Either<Failure, Movie>> getTVShowDetails({required String tvShowId}) async {
    if (await networkInfo.isConnected) {
      try {
        final tvShow = await remoteDataSource.getTVShowDetails(tvShowId: tvShowId);
        return Right(tvShow);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      ));
    }
  }

  // Implement remaining methods as needed...
  @override
  Future<Either<Failure, List<Movie>>> getMoviesByGenre({
    required String genreId,
    int page = 1,
  }) async {
    // Implement when needed
    return Left(UnknownFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, List<Movie>>> getTVShowsByGenre({
    required String genreId,
    int page = 1,
  }) async {
    // Implement when needed
    return Left(UnknownFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies({
    required String movieId,
    int page = 1,
  }) async {
    // Implement when needed
    return Left(UnknownFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, List<Movie>>> getSimilarTVShows({
    required String tvShowId,
    int page = 1,
  }) async {
    // Implement when needed
    return Left(UnknownFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, List<Movie>>> getMovieRecommendations({
    required String movieId,
    int page = 1,
  }) async {
    // Implement when needed
    return Left(UnknownFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, List<Movie>>> getTVShowRecommendations({
    required String tvShowId,
    int page = 1,
  }) async {
    // Implement when needed
    return Left(UnknownFailure(message: 'Not implemented'));
  }
}