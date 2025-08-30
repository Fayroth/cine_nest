import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/genre.dart';
import '../../../providers/movie_provider.dart';
import '../../widgets/cards/genre_card.dart';
import '../../widgets/cards/movie_card.dart';
import '../../widgets/dialogs/movie_details_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _searchController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchExpandAnimation;
  late Animation<double> _searchFadeAnimation;

  late TextEditingController _searchTextController;
  late FocusNode _searchFocusNode;

  bool isSearchActive = false;
  String searchQuery = '';
  String selectedGenre = 'All';
  List<Movie> searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _searchTextController = TextEditingController();
    _searchFocusNode = FocusNode();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _searchExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchController,
        curve: Curves.easeOutQuart,
      ),
    );

    _searchFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (isSearchActive) {
      _searchFocusNode.unfocus();
      _searchController.reverse().then((_) {
        if (mounted) {
          setState(() {
            isSearchActive = false;
            _searchTextController.clear();
            searchResults.clear();
            selectedGenre = 'All';
          });
        }
      });
    } else {
      setState(() {
        isSearchActive = true;
      });
      _searchController.forward();
      Future.delayed(Duration(milliseconds: 250), () {
        if (mounted && isSearchActive) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final repository = ref.read(movieRepositoryProvider);
    final result = await repository.searchMulti(query: query);

    result.fold(
          (failure) {
        setState(() {
          _isSearching = false;
          searchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
          (movies) {
        setState(() {
          _isSearching = false;
          searchResults = selectedGenre == 'All'
              ? movies
              : movies.where((m) => m.genre.contains(selectedGenre)).toList();
        });
      },
    );
  }

  void _selectGenre(String genre) {
    if (selectedGenre == genre) return;
    setState(() {
      selectedGenre = genre;
      if (_searchTextController.text.isNotEmpty) {
        // Re-filter search results
        _performSearch(_searchTextController.text);
      }
    });
  }

  void _showMovieDetails(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      enableDrag: true,
      builder: (context) => MovieDetailsSheet(
        movie: movie,
        onAddToWatchlist: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to watchlist'),
              backgroundColor: AppColors.cardBorder,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        onMoreInfo: () {
          // TODO: Navigate to full movie details page
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trendingMovies = ref.watch(trendingMoviesProvider);
    final popularMovies = ref.watch(popularMoviesProvider);
    final popularTVShows = ref.watch(popularTVShowsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/test'),
        backgroundColor: AppColors.accent,
        child: Icon(Icons.bug_report, color: AppColors.background),
        tooltip: 'Test API',
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: SizedBox(height: 20)),
                          if (!isSearchActive) _buildGenreCarousel(),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 16)),
                          if (!isSearchActive) _buildFeaturedSection(trendingMovies),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 32)),
                          if (!isSearchActive) _buildQuickActions(),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 32)),
                          if (!isSearchActive) _buildMovieSection('Popular Movies', popularMovies),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 32)),
                          if (!isSearchActive) _buildMovieSection('Popular TV Shows', popularTVShows),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 32)),
                          if (!isSearchActive) _buildTrendingSection(trendingMovies),
                          SliverToBoxAdapter(child: SizedBox(height: 100)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isSearchActive) _buildSearchOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.background,
      height: 90,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          if (isSearchActive)
            FadeTransition(
              opacity: _searchFadeAnimation,
              child: Container(
                width: 48,
                height: 48,
                child: Material(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _toggleSearch,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back,',
                  style: AppTextStyles.label,
                ),
                SizedBox(height: 2),
                Text(
                  'CineNest',
                  style: AppTextStyles.h1,
                ),
              ],
            ),

          if (isSearchActive) SizedBox(width: 16),
          if (!isSearchActive) Expanded(child: SizedBox()),

          if (isSearchActive)
            Expanded(
              child: ScaleTransition(
                scale: _searchExpandAnimation,
                alignment: Alignment.centerRight,
                child: FadeTransition(
                  opacity: _searchExpandAnimation,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder, width: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: FadeTransition(
                              opacity: _searchFadeAnimation,
                              child: TextField(
                                controller: _searchTextController,
                                focusNode: _searchFocusNode,
                                onChanged: _performSearch,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search movies, TV shows...',
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                          if (_searchTextController.text.isNotEmpty)
                            FadeTransition(
                              opacity: _searchFadeAnimation,
                              child: GestureDetector(
                                onTap: () {
                                  _searchTextController.clear();
                                  _performSearch('');
                                },
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.0).animate(_searchController),
              child: Container(
                width: 48,
                height: 48,
                child: Material(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _toggleSearch,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.search,
                          color: AppColors.accent,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenreCarousel() {
    return SliverToBoxAdapter(
      child: Container(
        height: 55,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: GenreData.genres.length,
          itemBuilder: (context, index) {
            final genre = GenreData.genres[index];
            return GenreCard(
              genre: genre,
              isSelected: selectedGenre == genre.name,
              onTap: () {
                setState(() {
                  selectedGenre = genre.name;
                });
                if (!isSearchActive) {
                  _toggleSearch();
                }
                _selectGenre(genre.name);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 90,
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _searchController,
          curve: Curves.easeOutCubic,
        )),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                height: 55,
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  physics: const BouncingScrollPhysics(),
                  itemCount: GenreData.genres.length,
                  itemBuilder: (context, index) {
                    final genre = GenreData.genres[index];
                    return GenreCard(
                      genre: genre,
                      isSelected: selectedGenre == genre.name,
                      onTap: () => _selectGenre(genre.name),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (searchResults.isEmpty && _searchTextController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: AppColors.textSecondary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: AppTextStyles.h2,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final columns = ResponsiveHelper.getGridColumns(screenWidth);

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            childAspectRatio: 0.65,
          ),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return MovieCardWithImage(
              movie: searchResults[index],
              onTap: () => _showMovieDetails(searchResults[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildFeaturedSection(AsyncValue<List<Movie>> trendingMovies) {
    return SliverToBoxAdapter(
      child: Container(
        height: 240,
        child: trendingMovies.when(
          data: (movies) {
            if (movies.isEmpty) return SizedBox();
            return LayoutBuilder(
              builder: (context, constraints) {
                double viewportFraction;
                if (constraints.maxWidth > 1200) {
                  viewportFraction = 0.4;
                } else if (constraints.maxWidth > 800) {
                  viewportFraction = 0.6;
                } else {
                  viewportFraction = 0.85;
                }

                return PageView.builder(
                  controller: PageController(
                    viewportFraction: viewportFraction,
                    initialPage: 0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  scrollBehavior: MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  itemCount: movies.length > 5 ? 5 : movies.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: _buildFeaturedCard(movies[index]),
                    );
                  },
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (error, stack) => Center(
            child: Text('Failed to load', style: AppTextStyles.body),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Movie movie) {
    return GestureDetector(
      onTap: () => _showMovieDetails(movie),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBorder,
              AppColors.cardBackground,
            ],
          ),
          border: Border.all(color: AppColors.cardBorderLight, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background image
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
                      child: Icon(
                        movie.type == ContentType.movie ? Icons.movie : Icons.tv,
                        color: AppColors.textSecondary.withOpacity(0.5),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: AppColors.accent, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${movie.rating.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${movie.year} • ${movie.genre}',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'My Collection',
                  style: AppTextStyles.h2,
                ),
                Spacer(),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      Container(
                        width: 280,
                        child: _buildActionCard('My Watchlist', Icons.bookmark_outline, '12 movies', 'watchlist'),
                      ),
                      SizedBox(width: 24),
                      Container(
                        width: 280,
                        child: _buildActionCard('My Ratings', Icons.star_outline, '47 rated', 'ratings'),
                      ),
                      Spacer(),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(child: _buildActionCard('My Watchlist', Icons.bookmark_outline, '12 movies', 'watchlist')),
                      SizedBox(width: 16),
                      Expanded(child: _buildActionCard('My Ratings', Icons.star_outline, '47 rated', 'ratings')),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, String subtitle, String destination) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/$destination');
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 24),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.bodyLarge,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.label,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieSection(String title, AsyncValue<List<Movie>> moviesProvider) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h2,
                ),
                Text(
                  'View All',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: moviesProvider.when(
              data: (movies) {
                if (movies.isEmpty) return SizedBox();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: movies.length > 10 ? 10 : movies.length,
                  itemBuilder: (context, index) {
                    return _buildMovieCardCompact(movies[index]);
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (error, stack) => Center(
                child: Text('Failed to load', style: AppTextStyles.body),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(AsyncValue<List<Movie>> trendingMovies) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending Now',
                  style: AppTextStyles.h2,
                ),
                Text(
                  'View All',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: trendingMovies.when(
              data: (movies) {
                if (movies.isEmpty) return SizedBox();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: movies.length > 10 ? 10 : movies.length,
                  itemBuilder: (context, index) {
                    return _buildMovieCardCompact(movies[index]);
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (error, stack) => Center(
                child: Text('Failed to load', style: AppTextStyles.body),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCardCompact(Movie movie) {
    return GestureDetector(
      onTap: () => _showMovieDetails(movie),
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorderLight, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: movie.posterUrl != null
                      ? CachedNetworkImage(
                    imageUrl: movie.posterUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
                      child: Icon(
                        movie.type == ContentType.movie ? Icons.movie : Icons.tv,
                        color: AppColors.textSecondary.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
                  )
                      : Container(
                    color: AppColors.cardBorder,
                    child: Icon(
                      movie.type == ContentType.movie ? Icons.movie : Icons.tv,
                      color: AppColors.textSecondary.withOpacity(0.5),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              movie.title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              '${movie.year} • ${movie.genre}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// New widget for movie cards with images
class MovieCardWithImage extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const MovieCardWithImage({
    Key? key,
    required this.movie,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: movie.posterUrl != null
                      ? CachedNetworkImage(
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
                      child: Icon(
                        movie.type == ContentType.movie ? Icons.movie : Icons.tv,
                        color: AppColors.textSecondary.withOpacity(0.5),
                        size: 32,
                      ),
                    ),
                  )
                      : Container(
                    color: AppColors.cardBorder,
                    child: Icon(
                      movie.type == ContentType.movie ? Icons.movie : Icons.tv,
                      color: AppColors.textSecondary.withOpacity(0.5),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      '${movie.year} • ${movie.genre}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
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
                            size: 14),
                        SizedBox(width: 4),
                        Text(
                          '${movie.rating.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Flexible(
                          child: Text(
                            movie.duration,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
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