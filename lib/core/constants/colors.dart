import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color cardBackground = Color(0xFF1A1F2E);
  static const Color cardBorder = Color(0xFF2A3142);
  static const Color cardBorderLight = Color(0xFF3A4155);

  // Accent colors
  static const Color accent = Color(0xFFE6B17A);
  static const Color accentHover = Color(0xFFD4A068);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8B94A8);
  static const Color textMuted = Color(0xFF8B94A8);

  // Status colors
  static const Color error = Colors.red;
  static const Color success = Color(0xFF4ECDC4);

  // Genre colors
  static const Map<String, Color> genreColors = {
    'All': accent,
    'Action': Color(0xFFFF6B6B),
    'Comedy': Color(0xFF4ECDC4),
    'Drama': Color(0xFF95E1D3),
    'Horror': Color(0xFF8B5CF6),
    'Sci-Fi': Color(0xFF7B68EE),
    'Romance': Color(0xFFFF6B9D),
    'Thriller': Color(0xFFF59E0B),
    'Crime': Color(0xFFEF4444),
  };
}