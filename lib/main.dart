import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart'; // Add this dependency

import 'package:cine_nest/UI/screens/HomeScreen.dart';
import 'package:cine_nest/UI/screens/WatchList.dart';
import 'package:cine_nest/UI/screens/RatingsScreen.dart';
import 'package:cine_nest/UI/screens/SearchDiscoverScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure window size limits (Desktop only)
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineNest',
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