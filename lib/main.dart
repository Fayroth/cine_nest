import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Conditional import for window_manager (only on desktop platforms)
import 'dart:io' show Platform;

import 'package:cine_nest/UI/screens/home/HomeScreen.dart';
import 'package:cine_nest/UI/screens/watchlist/WatchList.dart';
import 'package:cine_nest/UI/screens/ratings/RatingsScreen.dart';
import 'package:cine_nest/UI/screens/SearchDiscoverScreen.dart';

// Conditionally import window_manager only if available
import 'package:window_manager/window_manager.dart'
if (dart.library.html) 'package:cine_nest/stubs/window_manager_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only configure window manager on desktop platforms (not web)
  if (!kIsWeb) {
    try {
      // Check if we're on a desktop platform
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        await windowManager.ensureInitialized();

        WindowOptions windowOptions = WindowOptions(
          size: Size(1200, 800),        // Default size
          minimumSize: Size(800, 600),  // Minimum window size
          maximumSize: Size(2560, 1440), // Maximum window size
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineNest',
      theme: ThemeData(
        // Add a dark theme to match your app's aesthetic
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0E1A),
        primaryColor: Color(0xFFE6B17A),
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
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
          case '/search':
            return _createRoute(SearchDiscoverScreen(), settings);
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
      transitionDuration: Duration(milliseconds: 300), // Faster transition
      reverseTransitionDuration: Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Use a simple fade transition instead of the default slide
        // This reduces the workload during navigation
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