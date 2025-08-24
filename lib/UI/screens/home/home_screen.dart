import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/movie.dart';
import '../../../data/models/genre.dart';
import '../../widgets/cards/genre_card.dart';
import '../../widgets/cards/movie_card.dart';
import '../../widgets/dialogs/movie_details_sheet.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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

  // Cache for better performance
  List<Movie>? _filteredMovies;
  String? _lastSearchQuery;
  String? _lastGenre;

  // Sample movie data
  final List<Movie> allMovies = [
    Movie(
      id: '1',
      title: 'Dune: Part Two',
      year: 2024,
      genre: 'Sci-Fi',
      rating: 8.9,
      type: ContentType.movie,
      duration: '166 min',
      isInWatchlist: false,
      synopsis: 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
    ),
    Movie(
      id: '2',
      title: 'Shogun',
      year: 2024,
      genre: 'Drama',
      rating: 9.1,
      type: ContentType.tvShow,
      duration: 'TV Series',
      isInWatchlist: false,
      synopsis: 'An epic saga of political intrigue, cultural clash, and forbidden love set in feudal Japan.',
    ),
    Movie(
      id: '3',
      title: 'John Wick',
      year: 2014,
      genre: 'Action',
      rating: 7.4,
      type: ContentType.movie,
      duration: '101 min',
      isInWatchlist: false,
      synopsis: 'An ex-hitman comes out of retirement to track down the gangsters that killed his dog.',
    ),
    Movie(
      id: '4',
      title: 'The Office',
      year: 2005,
      genre: 'Comedy',
      rating: 9.0,
      type: ContentType.tvShow,
      duration: 'TV Series',
      isInWatchlist: true,
      synopsis: 'A mockumentary on a group of typical office workers.',
    ),
    Movie(
      id: '5',
      title: 'The Conjuring',
      year: 2013,
      genre: 'Horror',
      rating: 7.5,
      type: ContentType.movie,
      duration: '112 min',
      isInWatchlist: false,
      synopsis: 'Paranormal investigators work to help a family terrorized by a dark presence.',
    ),
    Movie(
      id: '6',
      title: 'The Notebook',
      year: 2004,
      genre: 'Romance',
      rating: 7.8,
      type: ContentType.movie,
      duration: '123 min',
      isInWatchlist: false,
      synopsis: 'A poor yet passionate young man falls in love with a rich young woman.',
    ),
    Movie(
      id: '7',
      title: 'Breaking Bad',
      year: 2008,
      genre: 'Crime',
      rating: 9.5,
      type: ContentType.tvShow,
      duration: 'TV Series',
      isInWatchlist: true,
      synopsis: 'A high school chemistry teacher turned methamphetamine producer.',
    ),
    Movie(
      id: '8',
      title: 'Inception',
      year: 2010,
      genre: 'Thriller',
      rating: 8.8,
      type: ContentType.movie,
      duration: '148 min',
      isInWatchlist: false,
      synopsis: 'A thief who steals corporate secrets through dream-sharing technology.',
    ),
    Movie(
      id: '9',
      title: 'Interstellar',
      year: 2014,
      genre: 'Sci-Fi',
      rating: 8.6,
      type: ContentType.movie,
      duration: '169 min',
      isInWatchlist: false,
      synopsis: 'A team of explorers travel through a wormhole in space to ensure humanity\'s survival.',
    ),
    Movie(
      id: '10',
      title: 'The Dark Knight',
      year: 2008,
      genre: 'Action',
      rating: 9.0,
      type: ContentType.movie,
      duration: '152 min',
      isInWatchlist: true,
      synopsis: 'When the menace known as the Joker wreaks havoc on Gotham.',
    ),
  ];

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
            _filteredMovies = null;
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
      _performSearch(_searchTextController.text);
    }
  }

  void _performSearch(String query) {
    if (_lastSearchQuery == query && _lastGenre == selectedGenre && _filteredMovies != null) {
      setState(() {
        searchResults = _filteredMovies!;
      });
      return;
    }

    setState(() {
      _lastSearchQuery = query;
      _lastGenre = selectedGenre;
      _filteredMovies = allMovies.where((movie) {
        final matchesQuery = query.isEmpty ||
            movie.title.toLowerCase().contains(query.toLowerCase());
        final matchesGenre = selectedGenre == 'All' || movie.genre == selectedGenre;
        return matchesQuery && matchesGenre;
      }).toList();
      searchResults = _filteredMovies!;
    });
  }

  void _selectGenre(String genre) {
    if (selectedGenre == genre) return;

    setState(() {
      selectedGenre = genre;
      _filteredMovies = null;
    });
    _performSearch(_searchTextController.text);
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
          setState(() {
            movie = movie.copyWith(isInWatchlist: !movie.isInWatchlist);
          });
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
    return Scaffold(
      backgroundColor: AppColors.background,
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
                          if (!isSearchActive) _buildFeaturedSection(),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 32)),
                          if (!isSearchActive) _buildQuickActions(),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 32)),
                          if (!isSearchActive) _buildRecentlyWatched(),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 32)),
                          if (!isSearchActive) _buildYourRatings(),
                          if (!isSearchActive) SliverToBoxAdapter(child: SizedBox(height: 32)),
                          if (!isSearchActive) _buildTrendingSection(),
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

          if (isSearchActive)
            SizedBox(width: 16),

          if (!isSearchActive)
            Expanded(child: SizedBox()),

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
    final results = searchResults.isNotEmpty || _searchTextController.text.isNotEmpty
        ? searchResults
        : (selectedGenre == 'All'
        ? allMovies
        : allMovies.where((movie) => movie.genre == selectedGenre).toList());

    if (results.isEmpty) {
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
          itemCount: results.length,
          itemBuilder: (context, index) {
            return MovieCard(
              movie: results[index],
              onTap: () {
                setState(() {
                  results[index] = results[index].copyWith(
                    isInWatchlist: !results[index].isInWatchlist,
                  );
                });
              },
              onLongPress: () => _showMovieDetails(results[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildFeaturedSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 240,
        child: LayoutBuilder(
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
                initialPage: 1000,
              ),
              physics: const BouncingScrollPhysics(),
              scrollBehavior: MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              itemBuilder: (context, index) {
                final actualIndex = index % 3;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: _buildFeaturedCard(actualIndex),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(int index) {
    final titles = ['Dune: Part Two', 'Oppenheimer', 'The Batman'];
    final ratings = [8.9, 8.7, 8.1];

    return Container(
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
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
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
                          '${ratings[index]}',
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
                    titles[index],
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to add to watchlist',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildRecentlyWatched() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Watched',
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildMovieCardCompact(allMovies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourRatings() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Top Rated',
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildMovieCardCompact(allMovies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildMovieCardCompact(allMovies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCardCompact(Movie movie) {
    return GestureDetector(
      onLongPress: () => _showMovieDetails(movie),
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
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.cardBorder,
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