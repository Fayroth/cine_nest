// lib/data/repositories/firebase_watchlist_repository.dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/failures.dart';
import '../models/movie.dart';
import '../services/firestore_service.dart';
import 'watchlist_repository.dart';

class FirebaseWatchlistRepository implements WatchlistRepository {
  final FirestoreService _firestoreService;

  FirebaseWatchlistRepository({required FirestoreService firestoreService})
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
  Future<Either<Failure, List<Movie>>> getWatchlist() async {
    return _userId.fold(
      Left.new,
      (uid) => _firestoreService.getWatchlist(uid),
    );
  }

  @override
  Future<Either<Failure, bool>> addToWatchlist(Movie movie) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.addToWatchlist(
          userId: uid,
          movie: movie,
        );
        return result.fold(Left.new, (_) => const Right(true));
      },
    );
  }

  @override
  Future<Either<Failure, bool>> removeFromWatchlist(String movieId) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.removeFromWatchlist(
          userId: uid,
          movieId: movieId,
        );
        return result.fold(Left.new, (_) => const Right(true));
      },
    );
  }

  @override
  Future<Either<Failure, bool>> isInWatchlist(String movieId) async {
    return _userId.fold(
      Left.new,
      (uid) => _firestoreService.isInWatchlist(
        userId: uid,
        movieId: movieId,
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> clearWatchlist() async {
    return _userId.fold(
      Left.new,
      (uid) async {
        try {
          final result = await _firestoreService.getWatchlist(uid);
          return result.fold(Left.new, (movies) async {
            for (final movie in movies) {
              await _firestoreService.removeFromWatchlist(
                userId: uid,
                movieId: movie.id,
              );
            }
            return const Right(true);
          });
        } catch (e) {
          return Left(ServerFailure(message: 'Failed to clear watchlist: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, int>> getWatchlistCount() async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getWatchlist(uid);
        return result.fold(Left.new, (movies) => Right(movies.length));
      },
    );
  }

  @override
  Future<Either<Failure, bool>> updateWatchlistItem(Movie movie) async {
    // Re-set the document with updated data (merge strategy)
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.addToWatchlist(
          userId: uid,
          movie: movie,
        );
        return result.fold(Left.new, (_) => const Right(true));
      },
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getWatchlistByType(
      ContentType type) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getWatchlist(uid);
        return result.fold(
          Left.new,
          (movies) => Right(movies.where((m) => m.type == type).toList()),
        );
      },
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getRecentlyAddedToWatchlist({
    int limit = 10,
  }) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getWatchlist(uid);
        return result.fold(Left.new, (movies) {
          final sorted = List<Movie>.from(movies)
            ..sort((a, b) => (b.dateAdded ?? DateTime(0))
                .compareTo(a.dateAdded ?? DateTime(0)));
          return Right(sorted.take(limit).toList());
        });
      },
    );
  }

  @override
  Future<Either<Failure, List<Movie>>> getSortedWatchlist({
    required String sortBy,
    bool ascending = true,
  }) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getWatchlist(uid);
        return result.fold(Left.new, (movies) {
          final sorted = List<Movie>.from(movies);
          switch (sortBy) {
            case 'title':
              sorted.sort((a, b) => ascending
                  ? a.title.compareTo(b.title)
                  : b.title.compareTo(a.title));
            case 'date_added':
              sorted.sort((a, b) => ascending
                  ? (a.dateAdded ?? DateTime(0))
                      .compareTo(b.dateAdded ?? DateTime(0))
                  : (b.dateAdded ?? DateTime(0))
                      .compareTo(a.dateAdded ?? DateTime(0)));
            case 'rating':
              sorted.sort((a, b) => ascending
                  ? a.rating.compareTo(b.rating)
                  : b.rating.compareTo(a.rating));
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
  Future<Either<Failure, List<Movie>>> searchWatchlist(String query) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getWatchlist(uid);
        return result.fold(Left.new, (movies) {
          final q = query.toLowerCase();
          return Right(
            movies
                .where((m) =>
                    m.title.toLowerCase().contains(q) ||
                    (m.synopsis?.toLowerCase().contains(q) ?? false))
                .toList(),
          );
        });
      },
    );
  }

  @override
  Future<Either<Failure, String>> exportWatchlist() async {
    return _userId.fold(
      Left.new,
      (uid) async {
        final result = await _firestoreService.getWatchlist(uid);
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
  Future<Either<Failure, bool>> importWatchlist(String data) async {
    return _userId.fold(
      Left.new,
      (uid) async {
        try {
          final List<dynamic> jsonList = jsonDecode(data);
          for (final item in jsonList) {
            final movie = Movie.fromJson(item as Map<String, dynamic>);
            await _firestoreService.addToWatchlist(userId: uid, movie: movie);
          }
          return const Right(true);
        } catch (e) {
          return Left(
              ServerFailure(message: 'Failed to import watchlist: $e'));
        }
      },
    );
  }
}
