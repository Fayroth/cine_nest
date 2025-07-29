import 'package:cine_nest/UI/screens/HomeScreen.dart';
import 'package:cine_nest/UI/screens/WatchList.dart';
import 'package:flutter/material.dart';

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
      routes: {
        '/home' : (context) => HomeScreen(),
        '/watchlist' : (context) => WatchlistScreen()
      },
      home: HomeScreen(),
    );
  }
}


