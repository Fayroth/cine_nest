import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../utils/logger.dart';

import '../../data/repositories/movie_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import '../../data/repositories/rating_repository.dart';
import '../../data/repositories/genre_repository.dart';

import '../../data/datasources/remote_data_source.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/remote_data_source_impl.dart';
import '../../data/repositories/movie_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize services first
  await _initExternal();

  // Core
  _initCore();

  // Data sources
  _initDataSources();

  // Repositories
  _initRepositories();

  // Providers (State Management)
  _initProviders();
}

void _initCore() {
  // Network
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(sl()),
  );

  // Utils
  sl.registerLazySingleton(() => Logger());
}

void _initDataSources() {
  // Remote Data Source
  sl.registerLazySingleton<RemoteDataSource>(
        () => RemoteDataSourceImpl(apiClient: sl()),
  );

  // Local Data Source
  // TODO: Implement LocalDataSourceImpl when you create local storage
  // sl.registerLazySingleton<LocalDataSource>(
  //   () => LocalDataSourceImpl(sharedPreferences: sl()),
  // );
}

void _initRepositories() {
  // Movie Repository
  sl.registerLazySingleton<MovieRepository>(
        () => MovieRepositoryImpl(
      remoteDataSource: sl(),
      // localDataSource: sl(), // Uncomment when local data source is ready
      networkInfo: sl(),
    ),
  );

  // Watchlist Repository
  // TODO: Implement WatchlistRepositoryImpl when you create local storage
  // sl.registerLazySingleton<WatchlistRepository>(
  //   () => WatchlistRepositoryImpl(
  //     localDataSource: sl(),
  //   ),
  // );

  // Rating Repository
  // TODO: Implement RatingRepositoryImpl when you create local storage
  // sl.registerLazySingleton<RatingRepository>(
  //   () => RatingRepositoryImpl(
  //     localDataSource: sl(),
  //   ),
  // );

  // Genre Repository
  // TODO: Implement GenreRepositoryImpl when you create local storage
  // sl.registerLazySingleton<GenreRepository>(
  //   () => GenreRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //   ),
  // );
}

void _initProviders() {
  // TODO: Register your state management providers here
  // Example with Riverpod or Provider
  // sl.registerFactory(() => MovieProvider(movieRepository: sl()));
  // sl.registerFactory(() => WatchlistProvider(watchlistRepository: sl()));
  // sl.registerFactory(() => RatingProvider(ratingRepository: sl()));
}

Future<void> _initExternal() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Dio
  sl.registerLazySingleton(() => Dio());

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
}