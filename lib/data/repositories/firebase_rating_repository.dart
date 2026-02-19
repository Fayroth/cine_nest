// lib/data/repositories/firebase_rating_repository.dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/failures.dart';
import '../models/movie.dart';
import '../models/rating.dart';
import '../services/firestore_service.dart';
import 'rating_repository.dart';

class FirebaseRatingRepository implements RatingRepository {
  final FirestoreService _firestoreService;

  FirebaseRatingRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  // Helper to get the current user ID, returns a Left if not signed in
  Either<Failure, String> get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Left(AuthFailure(message: 'User not authenticated'));
    }
    return Right(user.uid);
  }

  @override
  Future<Either<Failure, List<Movie>>> getRatedItems() async {
    return _userId.fold(
      Left.new,
      (uid) => _firestoreService.getRatings(uid),
    );
  }

  @override
  Future<Either<Failure, bool>> rateItem({
    required String movieId,
    required double rating,
    String? review,
  }) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        // We need the full movie object — fetch from existing ratings first,
        // then fall back to a minimal stub so the rating is never lost.
        final existing = await _firestoreService.getRatings(uid);
        Movie? movie = existing.fold(
          (_) => null,
          (movies) =>
              movies.where((m) => m.id == movieId).firstOrNull,
        );

        // If the movie wasn't rated before we won't have a full object here;
        // the caller is expected to pass the movie via the watchlist details
        // sheet which already holds it. As a safety net we build a stub.
        movie ??= Movie(
          id: movieId,
          title: '',
          year: 0,
          genre: '',
          rating: 0,
          duration: '',
          type: ContentType.movie,
        );

        final result = await _firestoreService.addOrUpdateRating(
          userId: uid,
          movie: movie,
          rating: rating,
          review: review,
        );
        return result.fold(Left.new, (_) => const Right(true));
      },
    );
  }

  @override
  Future<Either<Failure, bool>> removeRating(String movieId) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.removeRating(
          userId: uid,
          movieId: movieId,
        );
        return result.fold(Left.new, (_) => const Right(true));
      },
    );
  }

  @override
  Future<Either<Failure, Rating?>> getRating(String movieId) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(Left.new, (movies) {
          final movie =
              movies.where((m) => m.id == movieId).firstOrNull;
          if (movie == null) return const Right(null);
          return Right(Rating(
            movieId: movie.id,
            rating: movie.userRating ?? 0,
            review: movie.review,
            dateRated: movie.dateRated ?? DateTime.now(),
          ));
        });
      },
    );
  }

  @override
  Future<Either<Failure, bool>> updateReview({
    required String movieId,
    required String review,
  }) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        // Fetch the existing rated movie to preserve all its fields
        final existing = await _firestoreService.getRatings(uid);
        return existing.fold(Left.new, (movies) async {
          final movie =
              movies.where((m) => m.id == movieId).firstOrNull;
          if (movie == null) {
            return const Left(
                NotFoundFailure(message: 'Rating not found'));
          }
          final result = await _firestoreService.addOrUpdateRating(
            userId: uid,
            movie: movie,
            rating: movie.userRating ?? 0,
            review: review,
          );
          return result.fold(Left.new, (_) => const Right(true));
        });
      },
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getRatedItemsByRange({
    required double minRating,
    required double maxRating,
  }) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(Left.new, (movies) {
          return Right(movies
              .where((m) =>
                  (m.userRating ?? 0) >= minRating &&
                  (m.userRating ?? 0) <= maxRating)
              .toList());
        });
      },
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getPerfectScores() async {
    return getRatedItemsByRange(minRating: 10, maxRating: 10);
  }

  @override
  Future<Either<Failure, int>> getRatingsCount() async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(Left.new, (movies) => Right(movies.length));
      },
    );
  }

  @override
  Future<Either<Failure, double>> getAverageRating() async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(Left.new, (movies) {
          if (movies.isEmpty) return const Right(0.0);
          final total = movies.fold<double>(
              0, (sum, m) => sum + (m.userRating ?? 0));
          return Right(total / movies.length);
        });
      },
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getRatingsByType(
      ContentType type) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(
          Left.new,
          (movies) => Right(movies.where((m) => m.type == type).toList()),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getSortedRatings({
    required String sortBy,
    bool ascending = true,
  }) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(Left.new, (movies) {
          final sorted = List<Movie>.from(movies);
          switch (sortBy) {
            case 'rating':
              sorted.sort((a, b) => ascending
                  ? (a.userRating ?? 0).compareTo(b.userRating ?? 0)
                  : (b.userRating ?? 0).compareTo(a.userRating ?? 0));
            case 'date_rated':
              sorted.sort((a, b) => ascending
                  ? (a.dateRated ?? DateTime(0))
                      .compareTo(b.dateRated ?? DateTime(0))
                  : (b.dateRated ?? DateTime(0))
                      .compareTo(a.dateRated ?? DateTime(0)));
            case 'title':
              sorted.sort((a, b) => ascending
                  ? a.title.compareTo(b.title)
                  : b.title.compareTo(a.title));
            case 'year':
              sorted.sort((a, b) => ascending
                  ? a.year.compareTo(b.year)
                  : b.year.compareTo(a.year));
          }
          return Right(sorted);
        });
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRatingStatistics() async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(Left.new, (movies) {
          if (movies.isEmpty) {
            return const Right({
              'total': 0,
              'average': 0.0,
              'perfect': 0,
              'movies': 0,
              'tvShows': 0,
            });
          }

          final ratings =
              movies.map((m) => m.userRating ?? 0).toList();
          final total = ratings.fold<double>(0, (sum, r) => sum + r);

          return Right({
            'total': movies.length,
            'average': total / movies.length,
            'perfect':
                movies.where((m) => m.userRating == 10).length,
            'movies': movies
                .where((m) => m.type == ContentType.movie)
                .length,
            'tvShows': movies
                .where((m) => m.type == ContentType.tvShow)
                .length,
          });
        });
      },
    );
  }

  @override
  Future<Either<Failure, String>> exportRatings() async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(
          Left.new,
          (movies) => Right(
            jsonEncode(movies.map((m) => m.toJson()).toList()),
          ),
        );
      },
    );
  }

  @override
  Future<Either<Failure, bool>> importRatings(String data) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        try {
          final List<dynamic> jsonList = jsonDecode(data);
          for (final item in jsonList) {
            final movie = Movie.fromJson(item as Map<String, dynamic>);
            await _firestoreService.addOrUpdateRating(
              userId: uid,
              movie: movie,
              rating: movie.userRating ?? 0,
              review: movie.review,
            );
          }
          return const Right(true);
        } catch (e) {
          return Left(
              ServerFailure(message: 'Failed to import ratings: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getRecentlyRated({
    int limit = 10,
  }) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getRatings(uid);
        return result.fold(Left.new, (movies) {
          final sorted = List<Movie>.from(movies)
            ..sort((a, b) => (b.dateRated ?? DateTime(0))
                .compareTo(a.dateRated ?? DateTime(0)));
          return Right(sorted.take(limit).toList());
        });
      },
    );
  }
}
