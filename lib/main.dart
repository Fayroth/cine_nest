import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

// Dependency injection
import 'package:cine_nest/core/di/injection_container.dart' as di;

// Updated imports with new structure
import 'package:cine_nest/UI/screens/home/home_screen.dart';
import 'package:cine_nest/UI/screens/watchlist/watchlist_screen.dart';
import 'package:cine_nest/UI/screens/ratings/ratings_screen.dart';
import 'package:cine_nest/UI/screens/api_test_screen.dart';
import 'package:cine_nest/core/constants/colors.dart';

// Conditionally import window_manager only if available
import 'package:window_manager/window_manager.dart'
if (dart.library.html) 'package:cine_nest/stubs/window_manager_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize dependency injection
  await di.init();

  // Only configure window manager on desktop platforms (not web)
  if (!kIsWeb) {
    try {
      // Check if we're on a desktop platform
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        await windowManager.ensureInitialized();

        WindowOptions windowOptions = WindowOptions(
          size: Size(1200, 800),
          minimumSize: Size(800, 600),
          maximumSize: Size(2560, 1440),
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.normal,
        );

        windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
      }
    } catch (e) {
      // If Platform isn't available (shouldn't happen with kIsWeb check), just continue
      print('Window manager initialization skipped: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineNest',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accent,
          background: AppColors.background,
          surface: AppColors.cardBackground,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        // Custom route transitions for better performance
        switch (settings.name) {
          case '/home':
            return _createRoute(HomeScreen(), settings);
          case '/watchlist':
            return _createRoute(WatchlistScreen(), settings);
          case '/ratings':
            return _createRoute(RatingsScreen(), settings);
          case '/test':
            return _createRoute(ApiTestScreen(), settings);
          default:
            return _createRoute(HomeScreen(), settings);
        }
      },
      home: HomeScreen(),
    );
  }

  // Custom page route with optimized transition
  PageRoute _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: 300),
      reverseTransitionDuration: Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Use a simple fade transition for better performance
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
    );
  }
}