import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie.dart';
import '../data/models/rating.dart';
import '../data/repositories/rating_repository.dart';
import '../core/di/injection_container.dart';
import 'auth_provider.dart';

// Rating repository provider
final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return sl<RatingRepository>();
});

// Ratings state provider — invalidated automatically on every auth change
// so guest and signed-in users never share cached data.
final ratingsProvider = StateNotifierProvider<RatingsNotifier, AsyncValue<List<Movie>>>(
  (ref) {
    // Watch auth state: when the user changes this provider is recreated,
    // its notifier is disposed, and loadRatings() runs fresh for the new user.
    ref.watch(authStateProvider);
    return RatingsNotifier(ref.watch(ratingRepositoryProvider));
  },
);

// Rating sort provider
final ratingSortProvider = StateProvider<RatingSort>((ref) => RatingSort.recent);

// Rating filter provider
final ratingFilterProvider = StateProvider<RatingFilter>((ref) => RatingFilter.all);

// Filtered and sorted ratings provider
final filteredRatingsProvider = Provider<AsyncValue<List<Movie>>>((ref) {
  final ratings = ref.watch(ratingsProvider);
  final sort = ref.watch(ratingSortProvider);
  final filter = ref.watch(ratingFilterProvider);

  return ratings.whenData((movies) {
    // Apply filter
    var filtered = List<Movie>.from(movies);
    switch (filter) {
      case RatingFilter.all:
        break;
      case RatingFilter.perfect:
        filtered = filtered.where((m) => m.userRating == 10).toList();
        break;
      case RatingFilter.ninePlus:
        filtered = filtered.where((m) => (m.userRating ?? 0) >= 9).toList();
        break;
      case RatingFilter.eightPlus:
        filtered = filtered.where((m) => (m.userRating ?? 0) >= 8).toList();
        break;
      case RatingFilter.sevenPlus:
        filtered = filtered.where((m) => (m.userRating ?? 0) >= 7).toList();
        break;
      case RatingFilter.movies:
        filtered = filtered.where((m) => m.type == ContentType.movie).toList();
        break;
      case RatingFilter.tvShows:
        filtered = filtered.where((m) => m.type == ContentType.tvShow).toList();
        break;
    }

    // Apply sort
    switch (sort) {
      case RatingSort.recent:
        filtered.sort((a, b) => (b.dateRated ?? DateTime.now())
            .compareTo(a.dateRated ?? DateTime.now()));
        break;
      case RatingSort.highest:
        filtered.sort((a, b) => (b.userRating ?? 0).compareTo(a.userRating ?? 0));
        break;
      case RatingSort.lowest:
        filtered.sort((a, b) => (a.userRating ?? 0).compareTo(b.userRating ?? 0));
        break;
      case RatingSort.title:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filtered;
  });
});

// Get rating for specific movie
final movieRatingProvider = FutureProvider.family<Rating?, String>((ref, movieId) async {
  final repository = ref.watch(ratingRepositoryProvider);
  final result = await repository.getRating(movieId);

  return result.fold(
        (failure) => null,
        (rating) => rating,
  );
});

// Rating statistics provider
final ratingStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(ratingRepositoryProvider);
  final result = await repository.getRatingStatistics();

  return result.fold(
        (failure) => {},
        (stats) => stats,
  );
});

enum RatingSort {
  recent,
  highest,
  lowest,
  title,
}

enum RatingFilter {
  all,
  perfect,
  ninePlus,
  eightPlus,
  sevenPlus,
  movies,
  tvShows,
}

class RatingsNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final RatingRepository _repository;

  RatingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRatings();
  }

  Future<void> loadRatings() async {
    try {
      state = const AsyncValue.loading();
      final result = await _repository.getRatedItems();

      result.fold(
            (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
            (movies) => state = AsyncValue.data(movies),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> rateMovie({
    required String movieId,
    required double rating,
    String? review,
  }) async {
    try {
      final result = await _repository.rateItem(
        movieId: movieId,
        rating: rating,
        review: review,
      );

      return result.fold(
            (failure) => false,
            (success) {
          if (success) {
            loadRatings(); // Reload to get updated list
          }
          return success;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateReview({
    required String movieId,
    required String review,
  }) async {
    try {
      final result = await _repository.updateReview(
        movieId: movieId,
        review: review,
      );

      return result.fold(
            (failure) => false,
            (success) {
          if (success) {
            loadRatings(); // Reload to get updated list
          }
          return success;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeRating(String movieId) async {
    try {
      final result = await _repository.removeRating(movieId);

      return result.fold(
            (failure) => false,
            (success) {
          if (success) {
            state = state.whenData(
                  (movies) => movies.where((m) => m.id != movieId).toList(),
            );
          }
          return success;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<List<Movie>> getPerfectScores() async {
    try {
      final result = await _repository.getPerfectScores();

      return result.fold(
            (failure) => [],
            (movies) => movies,
      );
    } catch (e) {
      return [];
    }
  }
}