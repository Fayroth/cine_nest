import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/movie.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/movie_card.dart';
import '../../widgets/cards/movie_list_item.dart';
import '../../widgets/dialogs/watchlist_item_sheet.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedFilter = 'All';
  bool isGridView = true;

  final List<String> filters = ['All', 'Movies', 'TV Shows', 'Recently Added'];

  // Cache filtered items to avoid rebuilding
  List<Movie>? _cachedFilteredItems;
  String? _lastFilter;

  // Sample watchlist data using Movie model
  List<Movie> watchlistItems = [
    Movie(
      id: '1',
      title: 'Dune: Part Two',
      year: 2024,
      genre: 'Sci-Fi',
      duration: '166 min',
      rating: 8.9,
      type: ContentType.movie,
      dateAdded: DateTime.now().subtract(Duration(days: 2)),
      synopsis: 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
      isInWatchlist: true,
    ),
    Movie(
      id: '2',
      title: 'The Bear',
      year: 2022,
      genre: 'Comedy-Drama',
      duration: 'TV Series',
      rating: 8.7,
      type: ContentType.tvShow,
      dateAdded: DateTime.now().subtract(Duration(days: 7)),
      synopsis: 'A young chef from the fine dining world returns to Chicago to run his family\'s sandwich shop.',
      isInWatchlist: true,
    ),
    Movie(
      id: '3',
      title: 'Oppenheimer',
      year: 2023,
      genre: 'Biography',
      duration: '180 min',
      rating: 8.8,
      type: ContentType.movie,
      dateAdded: DateTime.now().subtract(Duration(days: 3)),
      synopsis: 'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb.',
      isInWatchlist: true,
    ),
    Movie(
      id: '4',
      title: 'The Last of Us',
      year: 2023,
      genre: 'Drama',
      duration: 'TV Series',
      rating: 9.1,
      type: ContentType.tvShow,
      dateAdded: DateTime.now().subtract(Duration(days: 5)),
      synopsis: 'In a post-apocalyptic world, a hardened survivor is hired to smuggle a 14-year-old girl out of an oppressive quarantine zone.',
      isInWatchlist: true,
    ),
    Movie(
      id: '5',
      title: 'Everything Everywhere All at Once',
      year: 2022,
      genre: 'Sci-Fi',
      duration: '139 min',
      rating: 8.7,
      type: ContentType.movie,
      dateAdded: DateTime.now().subtract(Duration(days: 7)),
      synopsis: 'An aging Chinese immigrant is swept up in an insane adventure where she alone can save the world.',
      isInWatchlist: true,
    ),
    Movie(
      id: '6',
      title: 'The Menu',
      year: 2022,
      genre: 'Thriller',
      duration: '107 min',
      rating: 7.2,
      type: ContentType.movie,
      dateAdded: DateTime.now().subtract(Duration(days: 14)),
      synopsis: 'A young couple travels to a remote island to eat at an exclusive restaurant where the chef has prepared a lavish menu.',
      isInWatchlist: true,
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

  List<Movie> get filteredItems {
    if (_lastFilter != selectedFilter || _cachedFilteredItems == null) {
      _lastFilter = selectedFilter;

      if (selectedFilter == 'All') {
        _cachedFilteredItems = watchlistItems;
      } else if (selectedFilter == 'Movies') {
        _cachedFilteredItems = watchlistItems.where((item) => item.type == ContentType.movie).toList();
      } else if (selectedFilter == 'TV Shows') {
        _cachedFilteredItems = watchlistItems.where((item) => item.type == ContentType.tvShow).toList();
      } else if (selectedFilter == 'Recently Added') {
        _cachedFilteredItems = List.from(watchlistItems)
          ..sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
      } else {
        _cachedFilteredItems = watchlistItems;
      }
    }

    return _cachedFilteredItems!;
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
        onMarkWatched: () {
          _showWatchedDialog(movie);
        },
        onRemove: () {
          _removeFromWatchlist(movie);
        },
        onMoreInfo: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening full details...'),
              backgroundColor: AppColors.cardBorder,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showWatchedDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mark as Watched',
          style: AppTextStyles.h3,
        ),
        content: Text(
          'Did you enjoy "${movie.title}"? You can rate it now!',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: AppColors.textSecondary)),
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

  void _removeFromWatchlist(Movie movie) {
    final removedMovie = movie;
    final removedIndex = watchlistItems.indexWhere((item) => item.id == movie.id);

    setState(() {
      watchlistItems.removeAt(removedIndex);
      _cachedFilteredItems = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from watchlist'),
        backgroundColor: AppColors.cardBorder,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.accent,
          onPressed: () {
            setState(() {
              watchlistItems.insert(removedIndex, removedMovie);
              _cachedFilteredItems = null;
            });
          },
        ),
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
                _buildStats(),
                _buildFilters(),
                Expanded(child: _buildWatchlist()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      title: 'My Watchlist',
      subtitle: '${filteredItems.length} items to watch',
      trailing: GestureDetector(
        onTap: () {
          setState(() {
            isGridView = !isGridView;
          });
        },
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

  Widget _buildStats() {
    final movieCount = watchlistItems.where((item) => item.type == ContentType.movie).length;
    final tvShowCount = watchlistItems.where((item) => item.type == ContentType.tvShow).length;
    final totalHours = movieCount * 2.5 + tvShowCount * 10;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                    AppColors.accent.withOpacity(0.1),
                    AppColors.accent.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem('${watchlistItems.length}', 'Total Items', Icons.bookmark),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.cardBorder,
                  ),
                  Expanded(
                    child: _buildStatItem('${totalHours.toInt()}h', 'Watch Time', Icons.access_time),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.cardBorder,
                  ),
                  Expanded(
                    child: _buildStatItem('$movieCount', 'Movies', Icons.movie),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
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
                  filter,
                  style: TextStyle(
                    color: isSelected ? AppColors.background : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWatchlist() {
    if (filteredItems.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_outline,
        title: 'Your watchlist is empty',
        subtitle: 'Start adding movies and shows\nyou want to watch later',
        buttonText: 'Explore Movies',
        onButtonPressed: () => Navigator.pop(context),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isGridView) {
          final screenWidth = constraints.maxWidth;
          final maxWidth = screenWidth > 1400 ? 1400.0 : screenWidth;

          return Center(
            child: Container(
              width: maxWidth,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildGridView(screenWidth),
            ),
          );
        } else {
          final maxWidth = constraints.maxWidth > 800 ? 800.0 : constraints.maxWidth;

          return Center(
            child: Container(
              width: maxWidth,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildListView(),
            ),
          );
        }
      },
    );
  }

  Widget _buildGridView(double screenWidth) {
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
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        Widget card = MovieCard(
          movie: filteredItems[index],
          onLongPress: () => _showItemDetails(filteredItems[index]),
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

  Widget _buildListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return MovieListItem(
          movie: filteredItems[index],
          onLongPress: () => _showItemDetails(filteredItems[index]),
          showDateAdded: true,
        );
      },
    );
  }
}