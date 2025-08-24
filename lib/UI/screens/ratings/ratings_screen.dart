import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/movie.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/cards/movie_list_item.dart';
import '../../widgets/dialogs/rating_details_sheet.dart';

class RatingsScreen extends StatefulWidget {
  @override
  _RatingsScreenState createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedSort = 'Recent';
  String selectedFilter = 'All';
  bool isEditMode = false;

  final List<String> sortOptions = ['Recent', 'Highest', 'Lowest', 'Title'];
  final List<String> filterOptions = ['All', '10/10', '9+', '8+', '7+', 'Movies', 'TV Shows'];

  // Sample rated items using Movie model
  final List<Movie> ratedItems = [
    Movie(
      id: '1',
      title: 'Interstellar',
      year: 2014,
      genre: 'Sci-Fi',
      duration: '169 min',
      rating: 8.8,
      userRating: 10,
      type: ContentType.movie,
      dateRated: DateTime.now().subtract(Duration(days: 2)),
      review: 'A masterpiece of science fiction cinema. Nolan at his best!',
    ),
    Movie(
      id: '2',
      title: 'Breaking Bad',
      year: 2008,
      genre: 'Crime Drama',
      duration: 'TV Series',
      rating: 9.5,
      userRating: 10,
      type: ContentType.tvShow,
      dateRated: DateTime.now().subtract(Duration(days: 7)),
      review: 'The best TV show ever made. Period.',
    ),
    Movie(
      id: '3',
      title: 'The Dark Knight',
      year: 2008,
      genre: 'Action',
      duration: '152 min',
      rating: 9.0,
      userRating: 9,
      type: ContentType.movie,
      dateRated: DateTime.now().subtract(Duration(days: 21)),
      review: 'Heath Ledger\'s performance is legendary',
    ),
    Movie(
      id: '4',
      title: 'Inception',
      year: 2010,
      genre: 'Sci-Fi',
      duration: '148 min',
      rating: 8.8,
      userRating: 9,
      type: ContentType.movie,
      dateRated: DateTime.now().subtract(Duration(days: 30)),
      review: null,
    ),
    Movie(
      id: '5',
      title: 'The Last of Us',
      year: 2023,
      genre: 'Drama',
      duration: 'TV Series',
      rating: 9.1,
      userRating: 8,
      type: ContentType.tvShow,
      dateRated: DateTime.now().subtract(Duration(days: 60)),
      review: 'Excellent adaptation, captures the essence of the game',
    ),
    Movie(
      id: '6',
      title: 'Pulp Fiction',
      year: 1994,
      genre: 'Crime',
      duration: '154 min',
      rating: 8.9,
      userRating: 7,
      type: ContentType.movie,
      dateRated: DateTime.now().subtract(Duration(days: 90)),
      review: null,
    ),
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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Movie> get filteredAndSortedItems {
    var filtered = List<Movie>.from(ratedItems);

    // Apply filter
    switch (selectedFilter) {
      case '10/10':
        filtered = filtered.where((item) => item.userRating == 10).toList();
        break;
      case '9+':
        filtered = filtered.where((item) => item.userRating! >= 9).toList();
        break;
      case '8+':
        filtered = filtered.where((item) => item.userRating! >= 8).toList();
        break;
      case '7+':
        filtered = filtered.where((item) => item.userRating! >= 7).toList();
        break;
      case 'Movies':
        filtered = filtered.where((item) => item.type == ContentType.movie).toList();
        break;
      case 'TV Shows':
        filtered = filtered.where((item) => item.type == ContentType.tvShow).toList();
        break;
    }

    // Apply sort
    switch (selectedSort) {
      case 'Highest':
        filtered.sort((a, b) => b.userRating!.compareTo(a.userRating!));
        break;
      case 'Lowest':
        filtered.sort((a, b) => a.userRating!.compareTo(b.userRating!));
        break;
      case 'Title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Recent':
      default:
        filtered.sort((a, b) => b.dateRated!.compareTo(a.dateRated!));
        break;
    }

    return filtered;
  }

  void _showRatingDetails(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingDetailsSheet(
        movie: movie,
        onSave: (rating, review) {
          setState(() {
            final index = ratedItems.indexWhere((item) => item.id == movie.id);
            if (index != -1) {
              ratedItems[index] = ratedItems[index].copyWith(
                userRating: rating,
                review: review,
              );
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                _buildCompactStats(),
                _buildFilters(),
                Expanded(child: _buildRatingsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      title: 'My Ratings',
      subtitle: '${filteredAndSortedItems.length} items rated',
      trailing: GestureDetector(
        onTap: () {
          setState(() {
            isEditMode = !isEditMode;
          });
        },
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

  Widget _buildCompactStats() {
    final totalRatings = ratedItems.length;
    final perfectScoreCount = ratedItems.where((item) => item.userRating == 10).length;

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
                  Icon(Icons.movie_filter, color: AppColors.textSecondary, size: 20),
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
                  Text(
                    'Rated',
                    style: AppTextStyles.label,
                  ),
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
                border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
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

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: CustomDropdown(
              value: selectedSort,
              items: sortOptions,
              onChanged: (value) => setState(() => selectedSort = value),
              hint: 'Sort',
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: CustomDropdown(
              value: selectedFilter,
              items: filterOptions,
              onChanged: (value) => setState(() => selectedFilter = value),
              hint: 'Filter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList() {
    final items = filteredAndSortedItems;

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
          showRating: true,
          isEditMode: isEditMode,
        );
      },
    );
  }
}