import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/movie.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/movie_card.dart';
import '../../widgets/cards/movie_list_item.dart';
import '../../widgets/dialogs/watchlist_item_sheet.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isGridView = true;

  final List<String> filters = ['All', 'Movies', 'TV Shows', 'Recently Added'];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showItemDetails(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      enableDrag: true,
      builder: (context) => WatchlistItemSheet(
        movie: movie,
        onMarkWatched: () => _showWatchedDialog(movie),
        onRemove: () => _removeFromWatchlist(movie),
        onMoreInfo: () {},
      ),
    );
  }

  void _showWatchedDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Mark as Watched', style: AppTextStyles.h3),
        content: Text(
          'Did you enjoy "${movie.title}"? You can rate it now!',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Later', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ratings');
            },
            child: Text('Rate Now', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFromWatchlist(Movie movie) async {
    final notifier = ref.read(watchlistProvider.notifier);
    final success = await notifier.removeFromWatchlist(movie.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Removed from watchlist' : 'Failed to remove'),
        backgroundColor: success ? AppColors.cardBorder : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: success
            ? SnackBarAction(
                label: 'Undo',
                textColor: AppColors.accent,
                onPressed: () => notifier.addToWatchlist(movie),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredWatchlistProvider);
    final allAsync = ref.watch(watchlistProvider);
    final selectedFilter = ref.watch(watchlistFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildAppBar(filteredAsync),
                _buildStats(allAsync),
                _buildFilters(selectedFilter),
                Expanded(child: _buildWatchlist(filteredAsync)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AsyncValue<List<Movie>> filteredAsync) {
    final count = filteredAsync.maybeWhen(data: (m) => m.length, orElse: () => 0);
    return CustomAppBar(
      title: 'My Watchlist',
      subtitle: '$count items to watch',
      trailing: GestureDetector(
        onTap: () => setState(() => isGridView = !isGridView),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Icon(
            isGridView ? Icons.view_list : Icons.grid_view,
            color: AppColors.accent,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildStats(AsyncValue<List<Movie>> allAsync) {
    final items = allAsync.maybeWhen(data: (m) => m, orElse: () => <Movie>[]);
    final movieCount =
        items.where((i) => i.type == ContentType.movie).length;
    final tvShowCount =
        items.where((i) => i.type == ContentType.tvShow).length;
    final totalHours = movieCount * 2.5 + tvShowCount * 10;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(builder: (context, constraints) {
        double statsWidth;
        if (constraints.maxWidth < 400) {
          statsWidth = constraints.maxWidth * 0.95;
        } else if (constraints.maxWidth < 800) {
          statsWidth = 360;
        } else if (constraints.maxWidth < 1200) {
          statsWidth = 420;
        } else {
          statsWidth = 480;
        }

        return Center(
          child: Container(
            width: statsWidth,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withValues(alpha: 0.1),
                  AppColors.accent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                      '${items.length}', 'Total Items', Icons.bookmark),
                ),
                Container(width: 1, height: 40, color: AppColors.cardBorder),
                Expanded(
                  child: _buildStatItem(
                      '${totalHours.toInt()}h', 'Watch Time', Icons.access_time),
                ),
                Container(width: 1, height: 40, color: AppColors.cardBorder),
                Expanded(
                  child: _buildStatItem(
                      '$movieCount', 'Movies', Icons.movie),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildFilters(WatchlistFilter selectedFilter) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _filterChip('All', WatchlistFilter.all, selectedFilter),
            _filterChip('Movies', WatchlistFilter.movies, selectedFilter),
            _filterChip('TV Shows', WatchlistFilter.tvShows, selectedFilter),
            _filterChip('Recently Added', WatchlistFilter.recentlyAdded,
                selectedFilter),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
      String label, WatchlistFilter filter, WatchlistFilter selectedFilter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () =>
          ref.read(watchlistFilterProvider.notifier).state = filter,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlist(AsyncValue<List<Movie>> filteredAsync) {
    return filteredAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: AppColors.accent)),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            SizedBox(height: 16),
            Text('Failed to load watchlist', style: AppTextStyles.h3),
            SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(watchlistProvider.notifier).loadWatchlist(),
              child: Text('Retry', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
      data: (movies) {
        if (movies.isEmpty) {
          return EmptyState(
            icon: Icons.bookmark_outline,
            title: 'Your watchlist is empty',
            subtitle: 'Start adding movies and shows\nyou want to watch later',
            buttonText: 'Explore Movies',
            onButtonPressed: () => Navigator.pop(context),
          );
        }

        return LayoutBuilder(builder: (context, constraints) {
          if (isGridView) {
            final screenWidth = constraints.maxWidth;
            final maxWidth = screenWidth > 1400 ? 1400.0 : screenWidth;
            return Center(
              child: Container(
                width: maxWidth,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _buildGridView(movies, screenWidth),
              ),
            );
          } else {
            final maxWidth =
                constraints.maxWidth > 800 ? 800.0 : constraints.maxWidth;
            return Center(
              child: Container(
                width: maxWidth,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _buildListView(movies),
              ),
            );
          }
        });
      },
    );
  }

  Widget _buildGridView(List<Movie> movies, double screenWidth) {
    final columns = ResponsiveHelper.getGridColumns(screenWidth);
    final maxCardWidth = ResponsiveHelper.getMaxCardWidth(screenWidth);

    return GridView.builder(
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: screenWidth < 500 ? 0.75 : 0.7,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        Widget card = MovieCard(
          movie: movies[index],
          onLongPress: () => _showItemDetails(movies[index]),
        );
        if (maxCardWidth != null) {
          card = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCardWidth),
            child: card,
          );
        }
        return card;
      },
    );
  }

  Widget _buildListView(List<Movie> movies) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return MovieListItem(
          movie: movies[index],
          onLongPress: () => _showItemDetails(movies[index]),
          showDateAdded: true,
        );
      },
    );
  }
}
