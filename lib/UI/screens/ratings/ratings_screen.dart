import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/movie.dart';
import '../../../providers/rating_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/cards/movie_list_item.dart';
import '../../widgets/dialogs/rating_details_sheet.dart';

class RatingsScreen extends ConsumerStatefulWidget {
  @override
  _RatingsScreenState createState() => _RatingsScreenState();
}

class _RatingsScreenState extends ConsumerState<RatingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isEditMode = false;

  final List<String> sortOptions = ['Recent', 'Highest', 'Lowest', 'Title'];
  final List<String> filterOptions = [
    'All',
    '10/10',
    '9+',
    '8+',
    '7+',
    'Movies',
    'TV Shows'
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _sortLabel(RatingSort sort) {
    switch (sort) {
      case RatingSort.recent:
        return 'Recent';
      case RatingSort.highest:
        return 'Highest';
      case RatingSort.lowest:
        return 'Lowest';
      case RatingSort.title:
        return 'Title';
    }
  }

  RatingSort _sortFromLabel(String label) {
    switch (label) {
      case 'Highest':
        return RatingSort.highest;
      case 'Lowest':
        return RatingSort.lowest;
      case 'Title':
        return RatingSort.title;
      default:
        return RatingSort.recent;
    }
  }

  String _filterLabel(RatingFilter filter) {
    switch (filter) {
      case RatingFilter.all:
        return 'All';
      case RatingFilter.perfect:
        return '10/10';
      case RatingFilter.ninePlus:
        return '9+';
      case RatingFilter.eightPlus:
        return '8+';
      case RatingFilter.sevenPlus:
        return '7+';
      case RatingFilter.movies:
        return 'Movies';
      case RatingFilter.tvShows:
        return 'TV Shows';
    }
  }

  RatingFilter _filterFromLabel(String label) {
    switch (label) {
      case '10/10':
        return RatingFilter.perfect;
      case '9+':
        return RatingFilter.ninePlus;
      case '8+':
        return RatingFilter.eightPlus;
      case '7+':
        return RatingFilter.sevenPlus;
      case 'Movies':
        return RatingFilter.movies;
      case 'TV Shows':
        return RatingFilter.tvShows;
      default:
        return RatingFilter.all;
    }
  }

  void _showRatingDetails(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingDetailsSheet(
        movie: movie,
        onSave: (rating, review) => _saveRating(movie, rating, review),
      ),
    );
  }

  Future<void> _saveRating(Movie movie, double rating, String? review) async {
    final notifier = ref.read(ratingsProvider.notifier);
    final success = await notifier.rateMovie(
      movieId: movie.id,
      rating: rating,
      review: review?.isEmpty == true ? null : review,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(success ? 'Rating saved' : 'Failed to save rating'),
        backgroundColor:
            success ? AppColors.cardBorder : AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _removeRating(Movie movie) async {
    final success =
        await ref.read(ratingsProvider.notifier).removeRating(movie.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Rating removed' : 'Failed to remove rating'),
        backgroundColor: success ? AppColors.cardBorder : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredRatingsProvider);
    final allAsync = ref.watch(ratingsProvider);
    final sort = ref.watch(ratingSortProvider);
    final filter = ref.watch(ratingFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    SizedBox(height: 12),
                    Text('Failed to load ratings',
                        style:
                            AppTextStyles.body.copyWith(color: AppColors.error)),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          ref.read(ratingsProvider.notifier).loadRatings(),
                      child:
                          Text('Retry', style: TextStyle(color: AppColors.accent)),
                    ),
                  ],
                ),
              ),
              data: (filteredItems) {
                final allItems = allAsync.valueOrNull ?? [];
                return Column(
                  children: [
                    _buildAppBar(filteredItems),
                    _buildCompactStats(allItems),
                    _buildFilters(sort, filter),
                    Expanded(child: _buildRatingsList(filteredItems)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(List<Movie> filteredItems) {
    return CustomAppBar(
      title: 'My Ratings',
      subtitle: '${filteredItems.length} items rated',
      trailing: GestureDetector(
        onTap: () => setState(() => isEditMode = !isEditMode),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isEditMode ? AppColors.accent : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEditMode ? AppColors.accent : AppColors.cardBorder,
              width: 1,
            ),
          ),
          child: Icon(
            isEditMode ? Icons.check : Icons.edit_outlined,
            color: isEditMode ? AppColors.background : AppColors.accent,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStats(List<Movie> allItems) {
    final totalRatings = allItems.length;
    final perfectScoreCount =
        allItems.where((item) => item.userRating == 10).length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter,
                      color: AppColors.textSecondary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '$totalRatings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('Rated', style: AppTextStyles.label),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    AppColors.accent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.accent.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: AppColors.accent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '$perfectScoreCount',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Perfect 10s',
                    style: TextStyle(
                      color: AppColors.accent.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(RatingSort sort, RatingFilter filter) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: CustomDropdown(
              value: _sortLabel(sort),
              items: sortOptions,
              onChanged: (value) => ref.read(ratingSortProvider.notifier).state =
                  _sortFromLabel(value),
              hint: 'Sort',
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: CustomDropdown(
              value: _filterLabel(filter),
              items: filterOptions,
              onChanged: (value) =>
                  ref.read(ratingFilterProvider.notifier).state =
                      _filterFromLabel(value),
              hint: 'Filter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList(List<Movie> items) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.star_outline,
        title: 'No ratings yet',
        subtitle: 'Start rating movies and shows\nto build your collection',
        buttonText: 'Discover Movies',
        onButtonPressed: () => Navigator.pop(context),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return MovieListItem(
          movie: items[index],
          onTap: () => _showRatingDetails(items[index]),
          onLongPress: isEditMode ? () => _removeRating(items[index]) : null,
          showRating: true,
          isEditMode: isEditMode,
        );
      },
    );
  }
}
