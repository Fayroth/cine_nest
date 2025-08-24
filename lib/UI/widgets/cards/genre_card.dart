import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/genre.dart';

class GenreCard extends StatelessWidget {
  final Genre genre;
  final bool isSelected;
  final VoidCallback onTap;

  const GenreCard({
    Key? key,
    required this.genre,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected ? [
              genre.color.withOpacity(0.3),
              genre.color.withOpacity(0.2),
            ] : [
              genre.color.withOpacity(0.2),
              genre.color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? genre.color.withOpacity(0.6)
                : genre.color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              genre.icon,
              color: genre.color,
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              genre.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}