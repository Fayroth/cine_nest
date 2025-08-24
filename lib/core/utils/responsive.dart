import 'package:flutter/material.dart';

class ResponsiveHelper {
  static int getGridColumns(double screenWidth) {
    if (screenWidth < 500) return 2;
    if (screenWidth < 750) return 3;
    if (screenWidth < 950) return 4;
    if (screenWidth < 1150) return 5;
    if (screenWidth < 1400) return 6;
    if (screenWidth < 1700) return 7;
    return 8;
  }

  static double? getMaxCardWidth(double screenWidth) {
    if (screenWidth > 1600) return 190;
    if (screenWidth > 1200) return 170;
    if (screenWidth > 900) return 160;
    return null;
  }

  static Map<String, double> getResponsiveFontSizes(double screenWidth) {
    if (screenWidth < 500) {
      return {
        'title': 15.0,
        'subtitle': 12.0,
        'rating': 11.0,
        'duration': 10.0,
      };
    } else if (screenWidth < 750) {
      return {
        'title': 16.0,
        'subtitle': 13.0,
        'rating': 12.0,
        'duration': 11.0,
      };
    } else if (screenWidth < 1200) {
      return {
        'title': 16.0,
        'subtitle': 13.0,
        'rating': 12.0,
        'duration': 11.0,
      };
    } else {
      return {
        'title': 15.0,
        'subtitle': 12.0,
        'rating': 11.0,
        'duration': 10.0,
      };
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return EdgeInsets.all(20);
    if (width < 1200) return EdgeInsets.all(24);
    return EdgeInsets.all(32);
  }
}