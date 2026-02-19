// lib/core/di/injection_container.dart
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

import '../../data/datasources/remote_data_source.dart';
import '../../data/datasources/remote_data_source_impl.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/firebase_watchlist_repository.dart';
import '../../data/repositories/firebase_rating_repository.dart';

// Firebase services
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize services first
  await _initExternal();

  // Core
  _initCore();

  // Firebase services
  _initFirebaseServices();

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

void _initFirebaseServices() {
  // Firebase Auth Service
  sl.registerLazySingleton(() => FirebaseAuthService());

  // Firestore Service
  sl.registerLazySingleton(() => FirestoreService());
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

  // Watchlist Repository (Firebase)
  sl.registerLazySingleton<WatchlistRepository>(
    () => FirebaseWatchlistRepository(
      firestoreService: sl(),
    ),
  );

  // Rating Repository (Firebase)
  sl.registerLazySingleton<RatingRepository>(
    () => FirebaseRatingRepository(
      firestoreService: sl(),
    ),
  );

  // Genre Repository
  // TODO: Implement GenreRepositoryImpl when local data source is ready
  // sl.registerLazySingleton<GenreRepository>(
  //   () => GenreRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //   ),
  // );
}

void _initProviders() {
  // Providers are registered in their respective provider files using Riverpod
  // This section is for any additional non-Riverpod dependencies
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