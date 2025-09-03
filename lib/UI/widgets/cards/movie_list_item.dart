import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/movie.dart';

class MovieListItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showRating;
  final bool showDateAdded;
  final bool isEditMode;

  const MovieListItem({
    Key? key,
    required this.movie,
    this.onTap,
    this.onLongPress,
    this.showRating = true,
    this.showDateAdded = false,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Movie poster
                    if (movie.posterUrl != null)
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: movie.posterUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.cardBorder,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.cardBorder,
                            child: Center(
                              child: Icon(
                                movie.type == ContentType.movie ? Icons.movie : Icons.tv,
                                color: AppColors.textSecondary.withOpacity(0.5),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Icon(
                          movie.type == ContentType.movie ? Icons.movie : Icons.tv,
                          color: AppColors.textSecondary.withOpacity(0.5),
                          size: 24,
                        ),
                      ),
                    // Edit mode delete button
                    if (isEditMode)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close,
                              color: AppColors.textPrimary,
                              size: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          style: AppTextStyles.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showRating && movie.userRating != null && !isEditMode)
                        _buildStarRating(movie.userRating!),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${movie.year} • ${movie.genre} • ${movie.duration}',
                    style: AppTextStyles.label,
                  ),
                  if (movie.review != null && movie.review!.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Text(
                      movie.review!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8),
                  Text(
                    showDateAdded
                        ? 'Added ${movie.getDateAddedString()}'
                        : 'Rated ${movie.getDateRatedString()}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    final starRating = rating / 2;
    final fullStars = starRating.floor();
    final hasHalfStar = starRating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < fullStars) {
            return Icon(Icons.star, color: AppColors.accent, size: 16);
          } else if (index == fullStars && hasHalfStar) {
            return Icon(Icons.star_half, color: AppColors.accent, size: 16);
          } else {
            return Icon(Icons.star_outline, color: AppColors.cardBorder, size: 16);
          }
        }),
        SizedBox(width: 4),
        Text(
          '${rating.toStringAsFixed(rating % 1 == 0 ? 0 : 1)}',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}