// lib/data/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/movie.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');

  // Get user document reference
  DocumentReference _userDoc(String userId) => _users.doc(userId);

  // Get user subcollections
  CollectionReference _watchlist(String userId) =>
      _userDoc(userId).collection('watchlist');

  CollectionReference _ratings(String userId) =>
      _userDoc(userId).collection('ratings');

  CollectionReference _favorites(String userId) =>
      _userDoc(userId).collection('favorites');

  CollectionReference _viewingHistory(String userId) =>
      _userDoc(userId).collection('viewing_history');

  // ============ User Profile Methods ============

  // Create user profile
  Future<Either<Failure, void>> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final profile = UserProfile(
        id: userId,
        email: email,
        displayName: displayName ?? 'CineNest User',
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: UserPreferences(),
      );

      await _userDoc(userId).set(profile.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create profile: $e'));
    }
  }

  // Get user profile
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final doc = await _userDoc(userId).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure(message: 'User profile not found'));
      }

      final profile = UserProfile.fromJson(
        doc.data() as Map<String, dynamic>,
      );

      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get profile: $e'));
    }
  }

  // Update user profile
  Future<Either<Failure, void>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    UserPreferences? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (preferences != null) updates['preferences'] = preferences.toJson();

      await _userDoc(userId).update(updates);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update profile: $e'));
    }
  }

  // ============ Watchlist Methods ============

  // Add to watchlist
  Future<Either<Failure, void>> addToWatchlist({
    required String userId,
    required Movie movie,
  }) async {
    try {
      final watchlistItem = {
        ...movie.toJson(),
        'dateAdded': FieldValue.serverTimestamp(),
      };

      await _watchlist(userId).doc(movie.id).set(watchlistItem);

      // Update user stats (set with merge so it works even if doc doesn't exist)
      await _userDoc(userId).set({
        'stats': {'watchlistCount': FieldValue.increment(1)},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add to watchlist: $e'));
    }
  }

  // Remove from watchlist
  Future<Either<Failure, void>> removeFromWatchlist({
    required String userId,
    required String movieId,
  }) async {
    try {
      await _watchlist(userId).doc(movieId).delete();

      // Update user stats
      await _userDoc(userId).set({
        'stats': {'watchlistCount': FieldValue.increment(-1)},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove from watchlist: $e'));
    }
  }

  // Get watchlist
  Future<Either<Failure, List<Movie>>> getWatchlist(String userId) async {
    try {
      final snapshot = await _watchlist(userId).get();

      final movies = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson(data);
      }).toList();

      // Sort client-side by dateAdded descending
      movies.sort((a, b) =>
          (b.dateAdded ?? DateTime(0)).compareTo(a.dateAdded ?? DateTime(0)));

      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get watchlist: $e'));
    }
  }

  // Stream watchlist (for real-time updates)
  Stream<List<Movie>> streamWatchlist(String userId) {
    return _watchlist(userId)
        .snapshots()
        .map((snapshot) {
          final movies = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Movie.fromJson(data);
          }).toList();
          movies.sort((a, b) =>
              (b.dateAdded ?? DateTime(0)).compareTo(a.dateAdded ?? DateTime(0)));
          return movies;
        });
  }

  // Check if in watchlist
  Future<Either<Failure, bool>> isInWatchlist({
    required String userId,
    required String movieId,
  }) async {
    try {
      final doc = await _watchlist(userId).doc(movieId).get();
      return Right(doc.exists);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check watchlist: $e'));
    }
  }

  // ============ Rating Methods ============

  // Add or update rating
  Future<Either<Failure, void>> addOrUpdateRating({
    required String userId,
    required Movie movie,
    required double rating,
    String? review,
  }) async {
    try {
      final ratingData = {
        ...movie.toJson(),
        'userRating': rating,
        'review': review,
        'dateRated': FieldValue.serverTimestamp(),
      };

      final docRef = _ratings(userId).doc(movie.id);
      final doc = await docRef.get();

      if (doc.exists) {
        // Update existing rating
        await docRef.update(ratingData);
      } else {
        // Create new rating
        await docRef.set(ratingData);

        // Update user stats for new rating
        await _userDoc(userId).set({
          'stats': {'ratingsCount': FieldValue.increment(1)},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add rating: $e'));
    }
  }

  // Remove rating
  Future<Either<Failure, void>> removeRating({
    required String userId,
    required String movieId,
  }) async {
    try {
      await _ratings(userId).doc(movieId).delete();

      // Update user stats
      await _userDoc(userId).set({
        'stats': {'ratingsCount': FieldValue.increment(-1)},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove rating: $e'));
    }
  }

  // Get ratings
  Future<Either<Failure, List<Movie>>> getRatings(String userId) async {
    try {
      final snapshot = await _ratings(userId).get();

      final movies = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson(data);
      }).toList();

      // Sort client-side by dateRated descending
      movies.sort((a, b) =>
          (b.dateRated ?? DateTime(0)).compareTo(a.dateRated ?? DateTime(0)));

      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get ratings: $e'));
    }
  }

  // Stream ratings (for real-time updates)
  Stream<List<Movie>> streamRatings(String userId) {
    return _ratings(userId)
        .snapshots()
        .map((snapshot) {
          final movies = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Movie.fromJson(data);
          }).toList();
          movies.sort((a, b) =>
              (b.dateRated ?? DateTime(0)).compareTo(a.dateRated ?? DateTime(0)));
          return movies;
        });
  }

  // ============ Favorites Methods ============

  // Add to favorites
  Future<Either<Failure, void>> addToFavorites({
    required String userId,
    required Movie movie,
  }) async {
    try {
      final favoriteItem = {
        ...movie.toJson(),
        'dateFavorited': FieldValue.serverTimestamp(),
      };

      await _favorites(userId).doc(movie.id).set(favoriteItem);

      // Update user stats
      await _userDoc(userId).set({
        'stats': {'favoritesCount': FieldValue.increment(1)},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add to favorites: $e'));
    }
  }

  // Remove from favorites
  Future<Either<Failure, void>> removeFromFavorites({
    required String userId,
    required String movieId,
  }) async {
    try {
      await _favorites(userId).doc(movieId).delete();

      // Update user stats
      await _userDoc(userId).set({
        'stats': {'favoritesCount': FieldValue.increment(-1)},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove from favorites: $e'));
    }
  }

  // Get favorites
  Future<Either<Failure, List<Movie>>> getFavorites(String userId) async {
    try {
      final snapshot = await _favorites(userId)
          .orderBy('dateFavorited', descending: true)
          .get();

      final movies = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson(data);
      }).toList();

      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get favorites: $e'));
    }
  }

  // ============ Viewing History Methods ============

  // Add to viewing history
  Future<Either<Failure, void>> addToViewingHistory({
    required String userId,
    required Movie movie,
  }) async {
    try {
      final historyItem = {
        ...movie.toJson(),
        'lastViewed': FieldValue.serverTimestamp(),
        'viewCount': FieldValue.increment(1),
      };

      await _viewingHistory(userId).doc(movie.id).set(
        historyItem,
        SetOptions(merge: true),
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add to history: $e'));
    }
  }

  // Get viewing history
  Future<Either<Failure, List<Movie>>> getViewingHistory(
      String userId, {
        int limit = 50,
      }) async {
    try {
      final snapshot = await _viewingHistory(userId)
          .orderBy('lastViewed', descending: true)
          .limit(limit)
          .get();

      final movies = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Movie.fromJson(data);
      }).toList();

      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get history: $e'));
    }
  }

  // Clear viewing history
  Future<Either<Failure, void>> clearViewingHistory(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _viewingHistory(userId).get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to clear history: $e'));
    }
  }

  // ============ Batch Operations ============

  // Get all user data
  Future<Either<Failure, Map<String, dynamic>>> getAllUserData(
      String userId,
      ) async {
    try {
      final results = await Future.wait([
        getUserProfile(userId),
        getWatchlist(userId),
        getRatings(userId),
        getFavorites(userId),
        getViewingHistory(userId),
      ]);

      // Check for failures
      for (final result in results) {
        if (result.isLeft()) {
          return Left(ServerFailure(message: 'Failed to get user data'));
        }
      }

      return Right({
        'profile': (results[0] as Right).value,
        'watchlist': (results[1] as Right).value,
        'ratings': (results[2] as Right).value,
        'favorites': (results[3] as Right).value,
        'history': (results[4] as Right).value,
      });
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user data: $e'));
    }
  }

  // Delete all user data (for account deletion)
  Future<Either<Failure, void>> deleteAllUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete subcollections
      final collections = [
        _watchlist(userId),
        _ratings(userId),
        _favorites(userId),
        _viewingHistory(userId),
      ];

      for (final collection in collections) {
        final snapshot = await collection.get();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      // Delete user document
      batch.delete(_userDoc(userId));

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete user data: $e'));
    }
  }
}