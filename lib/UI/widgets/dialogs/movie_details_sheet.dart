import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/movie.dart';

class MovieDetailsSheet extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onAddToWatchlist;
  final VoidCallback? onMoreInfo;

  const MovieDetailsSheet({
    Key? key,
    required this.movie,
    this.onAddToWatchlist,
    this.onMoreInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

        double dialogHeight;
        if (screenHeight < 700) {
          dialogHeight = screenHeight * 0.45;
        } else if (screenHeight < 900) {
          dialogHeight = screenHeight * 0.40;
        } else {
          dialogHeight = 380.0;
        }

        final minHeight = dialogHeight < 320 ? dialogHeight : 320.0;

        return Center(
          child: Container(
            width: maxWidth,
            constraints: BoxConstraints(
              maxHeight: dialogHeight,
              minHeight: minHeight,
            ),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
                _buildActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${movie.year} • ${movie.genre} • ${movie.duration}',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: AppColors.accent, size: 14),
                SizedBox(width: 4),
                Text(
                  movie.rating.toString(),
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Text(
        movie.synopsis ?? 'No synopsis available.',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onAddToWatchlist?.call();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_add,
                        color: AppColors.background,
                        size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Watchlist',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.background,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onMoreInfo?.call();
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorderLight, width: 1),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: AppColors.accent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}