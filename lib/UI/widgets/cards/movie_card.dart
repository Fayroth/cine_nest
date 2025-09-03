import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isCompact;

  const MovieCard({
    Key? key,
    required this.movie,
    this.onTap,
    this.onLongPress,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSizes = ResponsiveHelper.getResponsiveFontSizes(screenWidth);
    final isPhone = screenWidth < 500;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isPhone ? 3 : 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      // Movie poster image
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
                                  size: 32,
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
                            size: 32,
                          ),
                        ),
                      // Watchlist badge
                      if (movie.isInWatchlist)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.bookmark,
                              color: AppColors.background,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: isPhone ? 2 : 2,
              child: Padding(
                padding: EdgeInsets.all(isPhone ? 12 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: fontSizes['title']!,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: isPhone ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isPhone ? 6 : 5),
                    Text(
                      '${movie.year} • ${movie.genre}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: fontSizes['subtitle']!,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.star,
                            color: AppColors.accent,
                            size: fontSizes['rating']! + 2),
                        SizedBox(width: 4),
                        Text(
                          '${movie.rating}',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: fontSizes['rating']!,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Flexible(
                          child: Text(
                            movie.duration,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: fontSizes['duration']!,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}