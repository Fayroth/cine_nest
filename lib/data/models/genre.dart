import 'package:flutter/material.dart';

class Genre {
  final String name;
  final IconData icon;
  final Color color;

  const Genre({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class GenreData {
  static const List<Genre> genres = [
    Genre(name: 'All', icon: Icons.apps, color: Color(0xFFE6B17A)),
    Genre(name: 'Action', icon: Icons.sports_martial_arts, color: Color(0xFFFF6B6B)),
    Genre(name: 'Comedy', icon: Icons.mood, color: Color(0xFF4ECDC4)),
    Genre(name: 'Drama', icon: Icons.theater_comedy, color: Color(0xFF95E1D3)),
    Genre(name: 'Horror', icon: Icons.nightlight_round, color: Color(0xFF8B5CF6)),
    Genre(name: 'Sci-Fi', icon: Icons.rocket_launch, color: Color(0xFF7B68EE)),
    Genre(name: 'Romance', icon: Icons.favorite, color: Color(0xFFFF6B9D)),
    Genre(name: 'Thriller', icon: Icons.psychology, color: Color(0xFFF59E0B)),
    Genre(name: 'Crime', icon: Icons.gavel, color: Color(0xFFEF4444)),
  ];
}