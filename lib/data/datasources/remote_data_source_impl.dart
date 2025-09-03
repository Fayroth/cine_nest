import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import 'remote_data_source.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final ApiClient apiClient;

  RemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Movie>> getTrending({int page = 1, String timeWindow = 'week'}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/trending/all/$timeWindow',
        queryParameters: {
          'page': page,
        },
      );

      final results = response['results'] as List;
      return results.map((json) => _parseMovie(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch trending: $e');
    }
  }

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/movie/popular',
        queryParameters: {
          'page': page,
        },
      );

      final results = response['results'] as List;
      return results.map((json) => _parseMovie(json, type: ContentType.movie)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch popular movies: $e');
    }
  }

  @override
  Future<List<Movie>> getPopularTVShows({int page = 1}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/tv/popular',
        queryParameters: {
          'page': page,
        },
      );

      final results = response['results'] as List;
      return results.map((json) => _parseMovie(json, type: ContentType.tvShow)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch popular TV shows: $e');
    }
  }

  @override
  Future<List<Movie>> searchMulti({required String query, int page = 1}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/search/multi',
        queryParameters: {
          'query': query,
          'page': page,
        },
      );

      final results = response['results'] as List;
      return results
          .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
          .map((json) => _parseMovie(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search: $e');
    }
  }

  @override
  Future<Movie> getMovieDetails({required String movieId}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/movie/$movieId',
        queryParameters: {
          'append_to_response': 'credits,videos',
        },
      );

      return _parseMovieDetails(response, ContentType.movie);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch movie details: $e');
    }
  }

  @override
  Future<Movie> getTVShowDetails({required String tvShowId}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/tv/$tvShowId',
        queryParameters: {
          'append_to_response': 'credits,videos',
        },
      );

      return _parseMovieDetails(response, ContentType.tvShow);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch TV show details: $e');
    }
  }

  // Enhanced helper method to parse movie from JSON with better image handling
  Movie _parseMovie(Map<String, dynamic> json, {ContentType? type}) {
    // Determine content type
    ContentType contentType = type ??
        (json['media_type'] == 'tv' ? ContentType.tvShow : ContentType.movie);

    // Determine if it's a TV show based on the presence of certain fields
    if (type == null && json.containsKey('first_air_date') && !json.containsKey('release_date')) {
      contentType = ContentType.tvShow;
    }

    // Parse genres - TMDB returns genre_ids in list views
    String genreString = 'Unknown';
    if (json['genre_ids'] != null && (json['genre_ids'] as List).isNotEmpty) {
      genreString = _mapGenreIds(json['genre_ids'] as List);
    }

    // Parse runtime/duration
    String duration = 'Unknown';
    if (contentType == ContentType.movie && json['runtime'] != null) {
      duration = '${json['runtime']} min';
    } else if (contentType == ContentType.tvShow) {
      duration = 'TV Series';
    }

    // Create custom Movie object with both poster and backdrop URLs
    return MovieWithImages(
      id: json['id'].toString(),
      title: contentType == ContentType.tvShow
          ? (json['name'] ?? json['original_name'] ?? 'Unknown')
          : (json['title'] ?? json['original_title'] ?? 'Unknown'),
      year: _extractYear(
          contentType == ContentType.tvShow
              ? json['first_air_date']
              : json['release_date']
      ),
      genre: genreString,
      rating: (json['vote_average'] ?? 0).toDouble(),
      type: contentType,
      duration: duration,
      synopsis: json['overview'],
      posterUrl: json['poster_path'] != null
          ? '${ApiConstants.imageBaseUrl}${ApiConstants.posterSize}${json['poster_path']}'
          : null,
      backdropUrl: json['backdrop_path'] != null
          ? '${ApiConstants.imageBaseUrl}${ApiConstants.backdropSize}${json['backdrop_path']}'
          : null,
      isInWatchlist: false,
    );
  }

  // Helper method to parse detailed movie info
  Movie _parseMovieDetails(Map<String, dynamic> json, ContentType type) {
    // Parse genres from the detailed response
    String genreString = 'Unknown';
    if (json['genres'] != null && (json['genres'] as List).isNotEmpty) {
      final genres = (json['genres'] as List)
          .map((g) => g['name'] as String)
          .take(2)
          .join(', ');
      genreString = genres;
    }

    // Parse runtime/duration
    String duration = 'Unknown';
    if (type == ContentType.movie && json['runtime'] != null) {
      duration = '${json['runtime']} min';
    } else if (type == ContentType.tvShow) {
      if (json['episode_run_time'] != null &&
          (json['episode_run_time'] as List).isNotEmpty) {
        duration = '${json['episode_run_time'][0]} min/ep';
      } else {
        duration = 'TV Series';
      }
    }

    return MovieWithImages(
      id: json['id'].toString(),
      title: type == ContentType.tvShow
          ? (json['name'] ?? json['original_name'] ?? 'Unknown')
          : (json['title'] ?? json['original_title'] ?? 'Unknown'),
      year: _extractYear(
          type == ContentType.tvShow
              ? json['first_air_date']
              : json['release_date']
      ),
      genre: genreString,
      rating: (json['vote_average'] ?? 0).toDouble(),
      type: type,
      duration: duration,
      synopsis: json['overview'],
      posterUrl: json['poster_path'] != null
          ? '${ApiConstants.imageBaseUrl}${ApiConstants.posterSize}${json['poster_path']}'
          : null,
      backdropUrl: json['backdrop_path'] != null
          ? '${ApiConstants.imageBaseUrl}${ApiConstants.backdropSize}${json['backdrop_path']}'
          : null,
      isInWatchlist: false,
    );
  }

  // Helper to extract year from date string
  int _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return DateTime.now().year;
    try {
      return DateTime.parse(dateString).year;
    } catch (e) {
      return DateTime.now().year;
    }
  }

  // Simple genre ID mapping (you can expand this)
  String _mapGenreIds(List genreIds) {
    final Map<int, String> genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };

    if (genreIds.isEmpty) return 'Unknown';

    final genres = genreIds
        .take(2)
        .map((id) => genreMap[id] ?? 'Unknown')
        .where((name) => name != 'Unknown')
        .toList();

    return genres.isNotEmpty ? genres.join(', ') : 'Unknown';
  }

  // Implement remaining methods similarly...
  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/movie/top_rated',
        queryParameters: {'page': page},
      );
      final results = response['results'] as List;
      return results.map((json) => _parseMovie(json, type: ContentType.movie)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch top rated movies: $e');
    }
  }

  @override
  Future<List<Movie>> getTopRatedTVShows({int page = 1}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/tv/top_rated',
        queryParameters: {'page': page},
      );
      final results = response['results'] as List;
      return results.map((json) => _parseMovie(json, type: ContentType.tvShow)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch top rated TV shows: $e');
    }
  }

  // Other methods can be implemented as needed...
  @override
  Future<List<Genre>> getMovieGenres() async {
    // Implement when needed
    throw UnimplementedError();
  }

  @override
  Future<List<Genre>> getTVGenres() async {
    // Implement when needed
    throw UnimplementedError();
  }

  @override
  Future<List<Movie>> getMoviesByGenre({required String genreId, int page = 1}) async {
    // Implement when needed
    throw UnimplementedError();
  }

  @override
  Future<List<Movie>> getTVShowsByGenre({required String genreId, int page = 1}) async {
    // Implement when needed
    throw UnimplementedError();
  }

  @override
  Future<List<Movie>> getSimilarMovies({required String movieId, int page = 1}) async {
    // Implement when needed
    throw UnimplementedError();
  }

  @override
  Future<List<Movie>> getSimilarTVShows({required String tvShowId, int page = 1}) async {
    // Implement when needed
    throw UnimplementedError();
  }

  @override
  Future<List<Movie>> getMovieRecommendations({required String movieId, int page = 1}) async {
    // Implement when needed
    throw UnimplementedError();
  }

  @override
  Future<List<Movie>> getTVShowRecommendations({required String tvShowId, int page = 1}) async {
    // Implement when needed
    throw UnimplementedError();
  }
}

// Extended Movie class to include backdrop URL
class MovieWithImages extends Movie {
  final String? backdropUrl;

  MovieWithImages({
    required String id,
    required String title,
    required int year,
    required String genre,
    required double rating,
    required ContentType type,
    required String duration,
    String? synopsis,
    String? posterUrl,
    this.backdropUrl,
    bool isInWatchlist = false,
    DateTime? dateAdded,
    double? userRating,
    String? review,
    DateTime? dateRated,
  }) : super(
    id: id,
    title: title,
    year: year,
    genre: genre,
    rating: rating,
    type: type,
    duration: duration,
    synopsis: synopsis,
    posterUrl: posterUrl,
    isInWatchlist: isInWatchlist,
    dateAdded: dateAdded,
    userRating: userRating,
    review: review,
    dateRated: dateRated,
  );

  // Helper method to get the best image for different contexts
  String? getBestImageUrl({bool preferBackdrop = false}) {
    if (preferBackdrop && backdropUrl != null) {
      return backdropUrl;
    }
    return posterUrl ?? backdropUrl;
  }

  @override
  MovieWithImages copyWith({
    String? id,
    String? title,
    int? year,
    String? genre,
    double? rating,
    ContentType? type,
    String? synopsis,
    String? posterUrl,
    String? backdropUrl,
    String? duration,
    bool? isInWatchlist,
    DateTime? dateAdded,
    double? userRating,
    String? review,
    DateTime? dateRated,
  }) {
    return MovieWithImages(
      id: id ?? this.id,
      title: title ?? this.title,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      type: type ?? this.type,
      synopsis: synopsis ?? this.synopsis,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      duration: duration ?? this.duration,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      dateAdded: dateAdded ?? this.dateAdded,
      userRating: userRating ?? this.userRating,
      review: review ?? this.review,
      dateRated: dateRated ?? this.dateRated,
    );
  }
}