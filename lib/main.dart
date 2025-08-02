import 'package:flutter/material.dart';

import 'package:cine_nest/UI/screens/HomeScreen.dart';
import 'package:cine_nest/UI/screens/WatchList.dart';
import 'package:cine_nest/UI/screens/RatingsScreen.dart';

void main() {
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

// Alternative: If you prefer slide transitions, use this instead
class SlideRoute extends PageRouteBuilder {
  final Widget page;

  SlideRoute({required this.page, RouteSettings? settings})
      : super(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration(milliseconds: 300),
    reverseTransitionDuration: Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}