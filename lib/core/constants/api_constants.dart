class ApiConstants {
  // TMDB API Configuration
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = 'YOUR_API_KEY_HERE'; // Replace with your TMDB API key
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/';

  // Image sizes
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w185';

  // Endpoints
  static const String trending = '/trending/all/week';
  static const String popularMovies = '/movie/popular';
  static const String popularTVShows = '/tv/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String topRatedTVShows = '/tv/top_rated';
  static const String searchMulti = '/search/multi';
  static const String movieDetails = '/movie';
  static const String tvDetails = '/tv';
  static const String genres = '/genre/movie/list';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}