import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/movie.dart';
import '../data/repositories/movie_repository.dart';
import '../core/di/injection_container.dart';

// Movie repository provider
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return sl<MovieRepository>();
});

// State for trending movies
final trendingMoviesProvider = StateNotifierProvider<MovieListNotifier, AsyncValue<List<Movie>>>(
      (ref) => MovieListNotifier(ref.watch(movieRepositoryProvider), 'trending'),
);

// State for popular movies
final popularMoviesProvider = StateNotifierProvider<MovieListNotifier, AsyncValue<List<Movie>>>(
      (ref) => MovieListNotifier(ref.watch(movieRepositoryProvider), 'popular_movies'),
);

// State for popular TV shows
final popularTVShowsProvider = StateNotifierProvider<MovieListNotifier, AsyncValue<List<Movie>>>(
      (ref) => MovieListNotifier(ref.watch(movieRepositoryProvider), 'popular_tv'),
);

// State for top rated movies
final topRatedMoviesProvider = StateNotifierProvider<MovieListNotifier, AsyncValue<List<Movie>>>(
      (ref) => MovieListNotifier(ref.watch(movieRepositoryProvider), 'top_rated_movies'),
);

// State for top rated TV shows
final topRatedTVShowsProvider = StateNotifierProvider<MovieListNotifier, AsyncValue<List<Movie>>>(
      (ref) => MovieListNotifier(ref.watch(movieRepositoryProvider), 'top_rated_tv'),
);

// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Movie>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.searchMulti(query: query);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (movies) => movies,
  );
});

// Movie details provider
final movieDetailsProvider = FutureProvider.family<Movie, String>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);
  final result = await repository.getMovieDetails(movieId: movieId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (movie) => movie,
  );
});

// Generic movie list state notifier
class MovieListNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final MovieRepository _repository;
  final String _type;
  int _currentPage = 1;
  bool _hasMore = true;

  MovieListNotifier(this._repository, this._type) : super(const AsyncValue.loading()) {
    loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      state = const AsyncValue.loading();

      final result = await _fetchMovies();

      result.fold(
            (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
            (movies) => state = AsyncValue.data(movies),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    try {
      _currentPage++;
      final result = await _fetchMovies();

      result.fold(
            (failure) {
          _currentPage--; // Reset page on error
          // Don't update state to preserve existing data
        },
            (newMovies) {
          if (newMovies.isEmpty) {
            _hasMore = false;
          } else {
            state = state.whenData((movies) => [...movies, ...newMovies]);
          }
        },
      );
    } catch (e) {
      _currentPage--; // Reset page on error
    }
  }

  Future<dynamic> _fetchMovies() async {
    switch (_type) {
      case 'trending':
        return await _repository.getTrending(page: _currentPage);
      case 'popular_movies':
        return await _repository.getPopularMovies(page: _currentPage);
      case 'popular_tv':
        return await _repository.getPopularTVShows(page: _currentPage);
      case 'top_rated_movies':
        return await _repository.getTopRatedMovies(page: _currentPage);
      case 'top_rated_tv':
        return await _repository.getTopRatedTVShows(page: _currentPage);
      default:
        return await _repository.getTrending(page: _currentPage);
    }
  }

  void refresh() {
    _currentPage = 1;
    _hasMore = true;
    loadMovies();
  }
}