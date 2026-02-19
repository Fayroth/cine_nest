import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie.dart';
import '../data/repositories/watchlist_repository.dart';
import '../core/di/injection_container.dart';
import 'auth_provider.dart';

// Watchlist repository provider
final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return sl<WatchlistRepository>();
});

// Watchlist state provider — invalidated automatically on every auth change
// so guest and signed-in users never share cached data.
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<Movie>>>(
  (ref) {
    // Watch auth state: when the user changes this provider is recreated,
    // its notifier is disposed, and loadWatchlist() runs fresh for the new user.
    ref.watch(authStateProvider);
    return WatchlistNotifier(ref.watch(watchlistRepositoryProvider));
  },
);

// Filter provider for watchlist
final watchlistFilterProvider = StateProvider<WatchlistFilter>((ref) => WatchlistFilter.all);

// Filtered watchlist provider
final filteredWatchlistProvider = Provider<AsyncValue<List<Movie>>>((ref) {
  final watchlist = ref.watch(watchlistProvider);
  final filter = ref.watch(watchlistFilterProvider);

  return watchlist.whenData((movies) {
    switch (filter) {
      case WatchlistFilter.all:
        return movies;
      case WatchlistFilter.movies:
        return movies.where((m) => m.type == ContentType.movie).toList();
      case WatchlistFilter.tvShows:
        return movies.where((m) => m.type == ContentType.tvShow).toList();
      case WatchlistFilter.recentlyAdded:
        final sorted = List<Movie>.from(movies);
        sorted.sort((a, b) => (b.dateAdded ?? DateTime.now())
            .compareTo(a.dateAdded ?? DateTime.now()));
        return sorted.take(10).toList();
    }
  });
});

// Check if movie is in watchlist
final isInWatchlistProvider = Provider.family<bool, String>((ref, movieId) {
  final watchlist = ref.watch(watchlistProvider);
  return watchlist.maybeWhen(
    data: (movies) => movies.any((m) => m.id == movieId),
    orElse: () => false,
  );
});

enum WatchlistFilter {
  all,
  movies,
  tvShows,
  recentlyAdded,
}

class WatchlistNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final WatchlistRepository _repository;

  WatchlistNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    try {
      state = const AsyncValue.loading();
      final result = await _repository.getWatchlist();

      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (movies) => state = AsyncValue.data(movies),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addToWatchlist(Movie movie) async {
    try {
      final result = await _repository.addToWatchlist(movie);

      return result.fold(
            (failure) {
          // Handle error (show snackbar, etc.)
          return false;
        },
            (success) {
          if (success) {
            state = state.whenData((movies) => [...movies, movie]);
          }
          return success;
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromWatchlist(String movieId) async {
    try {
      final result = await _repository.removeFromWatchlist(movieId);

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

  Future<bool> toggleWatchlist(Movie movie) async {
    final isInList = state.maybeWhen(
      data: (movies) => movies.any((m) => m.id == movie.id),
      orElse: () => false,
    );

    if (isInList) {
      return await removeFromWatchlist(movie.id);
    } else {
      return await addToWatchlist(movie);
    }
  }

  Future<void> clearWatchlist() async {
    try {
      final result = await _repository.clearWatchlist();

      result.fold(
            (failure) => null,
            (success) {
          if (success) {
            state = const AsyncValue.data([]);
          }
        },
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> sortWatchlist(String sortBy, {bool ascending = true}) async {
    try {
      final result = await _repository.getSortedWatchlist(
        sortBy: sortBy,
        ascending: ascending,
      );

      result.fold(
            (failure) => null,
            (movies) => state = AsyncValue.data(movies),
      );
    } catch (e) {
      // Handle error
    }
  }
}