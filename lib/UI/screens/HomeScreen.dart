import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
  List<Map<String, dynamic>> searchResults = [];

  // Cache for better performance
  List<Map<String, dynamic>>? _filteredMovies;
  String? _lastSearchQuery;
  String? _lastGenre;

  // Genre data with icons and colors
  final List<Map<String, dynamic>> genres = [
    {'name': 'All', 'icon': Icons.apps, 'color': Color(0xFFE6B17A)},
    {'name': 'Action', 'icon': Icons.sports_martial_arts, 'color': Color(0xFFFF6B6B)},
    {'name': 'Comedy', 'icon': Icons.mood, 'color': Color(0xFF4ECDC4)},
    {'name': 'Drama', 'icon': Icons.theater_comedy, 'color': Color(0xFF95E1D3)},
    {'name': 'Horror', 'icon': Icons.nightlight_round, 'color': Color(0xFF8B5CF6)},
    {'name': 'Sci-Fi', 'icon': Icons.rocket_launch, 'color': Color(0xFF7B68EE)},
    {'name': 'Romance', 'icon': Icons.favorite, 'color': Color(0xFFFF6B9D)},
    {'name': 'Thriller', 'icon': Icons.psychology, 'color': Color(0xFFF59E0B)},
    {'name': 'Crime', 'icon': Icons.gavel, 'color': Color(0xFFEF4444)},
  ];

  // Sample movie data
  final List<Map<String, dynamic>> allMovies = [
    {
      'title': 'Dune: Part Two',
      'year': '2024',
      'genre': 'Sci-Fi',
      'rating': 8.9,
      'type': 'Movie',
      'isInWatchlist': false,
    },
    {
      'title': 'Shogun',
      'year': '2024',
      'genre': 'Drama',
      'rating': 9.1,
      'type': 'TV Show',
      'isInWatchlist': false,
    },
    {
      'title': 'John Wick',
      'year': '2014',
      'genre': 'Action',
      'rating': 7.4,
      'type': 'Movie',
      'isInWatchlist': false,
    },
    {
      'title': 'The Office',
      'year': '2005',
      'genre': 'Comedy',
      'rating': 9.0,
      'type': 'TV Show',
      'isInWatchlist': true,
    },
    {
      'title': 'The Conjuring',
      'year': '2013',
      'genre': 'Horror',
      'rating': 7.5,
      'type': 'Movie',
      'isInWatchlist': false,
    },
    {
      'title': 'The Notebook',
      'year': '2004',
      'genre': 'Romance',
      'rating': 7.8,
      'type': 'Movie',
      'isInWatchlist': false,
    },
    {
      'title': 'Breaking Bad',
      'year': '2008',
      'genre': 'Crime',
      'rating': 9.5,
      'type': 'TV Show',
      'isInWatchlist': true,
    },
    {
      'title': 'Inception',
      'year': '2010',
      'genre': 'Thriller',
      'rating': 8.8,
      'type': 'Movie',
      'isInWatchlist': false,
    },
  ];

  @override
  void initState() {
    super.initState();

    _searchTextController = TextEditingController();
    _searchFocusNode = FocusNode();

    // Optimized animation durations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: Duration(milliseconds: 350), // Optimized duration
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
        curve: Curves.easeOutQuart, // Smoother curve
      ),
    );

    _searchFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut), // Later start for less overlap
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
      // When exiting search - simplified animation
      _searchFocusNode.unfocus();

      // Single coordinated animation
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
      // Activate search
      setState(() {
        isSearchActive = true;
      });

      _searchController.forward();

      // Delayed focus to avoid conflict with animation
      Future.delayed(Duration(milliseconds: 250), () {
        if (mounted && isSearchActive) {
          _searchFocusNode.requestFocus();
        }
      });
      _performSearch(_searchTextController.text);
    }
  }

  void _performSearch(String query) {
    // Use caching to improve performance
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
            movie['title'].toString().toLowerCase().contains(query.toLowerCase());
        final matchesGenre = selectedGenre == 'All' || movie['genre'] == selectedGenre;
        return matchesQuery && matchesGenre;
      }).toList();
      searchResults = _filteredMovies!;
    });
  }

  void _selectGenre(String genre) {
    if (selectedGenre == genre) return;

    setState(() {
      selectedGenre = genre;
      _filteredMovies = null; // Clear cache when genre changes
    });
    _performSearch(_searchTextController.text);
  }

  void _showMovieDetails({
    required String title,
    required String year,
    required String genre,
    required String duration,
    required double rating,
    required String synopsis,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      enableDrag: true,
      builder: (context) => _MovieDetailsSheet(
        title: title,
        year: year,
        genre: genre,
        duration: duration,
        rating: rating,
        synopsis: synopsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Fixed header - keep original height and styling
                _buildHeader(),
                // Scrollable content - removed blur animation
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Add spacing to prevent overlap with header
                          SliverToBoxAdapter(child: SizedBox(height: 20)), // Added proper top padding
                          // Move genre carousel higher and make it non-overlapping
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
            // Search overlay - positioned more precisely
            if (isSearchActive) _buildSearchOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Color(0xFF0A0E1A),
      height: 90,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Welcome text or back button
          if (isSearchActive)
          // Back button when searching - with fade animation
            FadeTransition(
              opacity: _searchFadeAnimation,
              child: Container(
                width: 48,
                height: 48,
                child: Material(
                  color: Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _toggleSearch,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF2A3142), width: 1),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
          // Welcome text when not searching
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Color(0xFF8B94A8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'CineNest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

          // Spacer between back button and search bar when searching
          if (isSearchActive)
            SizedBox(width: 16),

          // Expanding spacer when not searching
          if (!isSearchActive)
            Expanded(child: SizedBox()),

          // Search bar or search button
          if (isSearchActive)
          // Search bar when active - takes remaining space
            Expanded(
              child: ScaleTransition(
                scale: _searchExpandAnimation,
                alignment: Alignment.centerRight,
                child: FadeTransition(
                  opacity: _searchExpandAnimation, // Use same animation for consistency
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFF2A3142), width: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Color(0xFF8B94A8),
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
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search movies, TV shows...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF8B94A8),
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
                                  color: Color(0xFF8B94A8),
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
          // Search button when not active - always on the right
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.0).animate(_searchController),
              child: Container(
                width: 48,
                height: 48,
                child: Material(
                  color: Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _toggleSearch,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF2A3142), width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.search,
                          color: Color(0xFFE6B17A),
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
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            return _buildGenreCard(genre);
          },
        ),
      ),
    );
  }

  Widget _buildGenreCard(Map<String, dynamic> genre) {
    final isSelected = selectedGenre == genre['name'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGenre = genre['name'];
        });
        if (!isSearchActive) {
          _toggleSearch();
        }
        _selectGenre(genre['name']);
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected ? [
              (genre['color'] as Color).withOpacity(0.3),
              (genre['color'] as Color).withOpacity(0.2),
            ] : [
              (genre['color'] as Color).withOpacity(0.2),
              (genre['color'] as Color).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (genre['color'] as Color).withOpacity(0.6)
                : (genre['color'] as Color).withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              genre['icon'] as IconData,
              color: genre['color'] as Color,
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              genre['name'] as String,
              style: TextStyle(
                color: Colors.white,
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

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 90, // Position right after header
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
            color: Color(0xFF0A0E1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Color(0xFF2A3142), width: 1),
          ),
          child: Column(
            children: [
              // Proper top padding for the container
              SizedBox(height: 20),
              // Genre carousel inside the search overlay container
              Container(
                height: 55,
                padding: EdgeInsets.symmetric(horizontal: 12), // Reduced padding
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  physics: const BouncingScrollPhysics(),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    return _buildGenreCard(genre);
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
        : (selectedGenre == 'All' ? allMovies : allMovies.where((movie) => movie['genre'] == selectedGenre).toList());

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Color(0xFF8B94A8),
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Responsive columns similar to watchlist
        int columns;
        if (screenWidth < 500) {
          columns = 2; // Phones: 2 columns
        } else if (screenWidth < 750) {
          columns = 3; // Large phones/small tablets
        } else if (screenWidth < 950) {
          columns = 4; // Tablets
        } else {
          columns = 5; // Larger screens
        }

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: screenWidth < 500 ? 0.75 : 0.7, // Taller on phones
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return _buildSearchResultCard(results[index], screenWidth);
          },
        );
      },
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> item, double screenWidth) {
    final isPhone = screenWidth < 500;

    // Responsive font sizes
    Map<String, double> fontSizes;
    if (screenWidth < 500) {
      fontSizes = {
        'title': 15.0,
        'subtitle': 12.0,
        'rating': 11.0,
      };
    } else if (screenWidth < 750) {
      fontSizes = {
        'title': 14.0,
        'subtitle': 11.0,
        'rating': 10.0,
      };
    } else {
      fontSizes = {
        'title': 13.0,
        'subtitle': 10.0,
        'rating': 10.0,
      };
    }

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF2A3142), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster area
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A3142),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
                // Bookmark button in top-right corner
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        item['isInWatchlist'] = !item['isInWatchlist'];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: item['isInWatchlist']
                            ? Color(0xFFE6B17A)
                            : Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['isInWatchlist']
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: item['isInWatchlist']
                            ? Color(0xFF0A0E1A)
                            : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info area with better space management
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(isPhone ? 12 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - single line only
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizes['title']!,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1, // Single line as requested
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isPhone ? 6 : 4),
                  // Subtitle
                  Text(
                    '${item['year']} • ${item['type']}',
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: fontSizes['subtitle']!,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Spacer to push rating to bottom
                  Spacer(),
                  // Rating row
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFE6B17A), size: fontSizes['rating']! + 2),
                      SizedBox(width: 4),
                      Text(
                        '${item['rating']}',
                        style: TextStyle(
                          color: Color(0xFFE6B17A),
                          fontSize: fontSizes['rating']!,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildFeaturedSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 240,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate appropriate viewport fraction based on screen width
            double viewportFraction;
            if (constraints.maxWidth > 1200) {
              viewportFraction = 0.4; // Much smaller on large screens
            } else if (constraints.maxWidth > 800) {
              viewportFraction = 0.6; // Medium on tablets/small laptops
            } else {
              viewportFraction = 0.85; // Original size on phones
            }

            return PageView.builder(
              controller: PageController(
                viewportFraction: viewportFraction,
                initialPage: 1000, // Start in the middle for infinite effect
              ),
              physics: const BouncingScrollPhysics(),
              // Enable mouse drag for desktop
              scrollBehavior: MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              itemBuilder: (context, index) {
                // Use modulo to cycle through the 3 featured items infinitely
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
            Color(0xFF2A3142),
            Color(0xFF1A1F2E),
          ],
        ),
        border: Border.all(color: Color(0xFF3A4155), width: 1),
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
                      color: Color(0xFFE6B17A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE6B17A), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Color(0xFFE6B17A), size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${ratings[index]}',
                          style: TextStyle(
                            color: Color(0xFFE6B17A),
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
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to add to watchlist',
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: 14,
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

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'My Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Action cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // On larger screens, align to the left instead of centering
                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      // Fixed width cards on the left
                      Container(
                        width: 280,
                        child: _buildActionCard('My Watchlist', Icons.bookmark_outline, '12 movies', 'watchlist'),
                      ),
                      SizedBox(width: 24),
                      Container(
                        width: 280,
                        child: _buildActionCard('My Ratings', Icons.star_outline, '47 rated', 'ratings'),
                      ),
                      // Spacer pushes everything to the left and fills the remaining space
                      Spacer(),
                    ],
                  );
                } else {
                  // On smaller screens, use full width with Expanded (unchanged)
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
          color: Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF2A3142), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFE6B17A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Color(0xFFE6B17A), size: 24),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Color(0xFF8B94A8),
                fontSize: 14,
              ),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFE6B17A),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                return _buildMovieCard(index, isSmall: true);
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFE6B17A),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                return _buildMovieCard(index, isSmall: true);
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFE6B17A),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                return _buildMovieCard(index, isSmall: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(int index, {bool isSmall = false}) {
    final titles = ['Interstellar', 'Inception', 'The Dark Knight', 'Pulp Fiction', 'Fight Club'];
    final ratings = [9.2, 9.0, 8.8, 8.9, 8.7];
    final years = ['2014', '2010', '2008', '1994', '1999'];
    final genres = ['Sci-Fi', 'Sci-Fi', 'Action', 'Crime', 'Drama'];
    final durations = ['169 min', '148 min', '152 min', '154 min', '139 min'];
    final synopses = [
      'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
      'A thief who steals corporate secrets through dream-sharing technology is given the inverse task of planting an idea.',
      'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests.',
      'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.',
      'An insomniac office worker and a devil-may-care soap maker form an underground fight club that evolves into much more.'
    ];

    return GestureDetector(
      onLongPress: () {
        _showMovieDetails(
          title: titles[index],
          year: years[index],
          genre: genres[index],
          duration: durations[index],
          rating: ratings[index],
          synopsis: synopses[index],
        );
      },
      child: Container(
        width: isSmall ? 120 : 160,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2A3142),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF3A4155), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Color(0xFF2A3142),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              titles[index],
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              '${years[index]} • ${genres[index]}',
              style: TextStyle(
                color: Color(0xFF8B94A8),
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

class _MovieDetailsSheet extends StatelessWidget {
  final String title;
  final String year;
  final String genre;
  final String duration;
  final double rating;
  final String synopsis;

  const _MovieDetailsSheet({
    required this.title,
    required this.year,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.synopsis,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

        // Compact height for quick info card
        double dialogHeight;
        if (screenHeight < 700) {
          dialogHeight = screenHeight * 0.45; // Very small phones
        } else if (screenHeight < 900) {
          dialogHeight = screenHeight * 0.40; // Regular phones
        } else {
          dialogHeight = 380.0; // Fixed max height for larger screens
        }

        // Fix: Ensure minHeight is never greater than maxHeight
        final minHeight = dialogHeight < 320 ? dialogHeight : 320.0;

        return Center(
          child: Container(
            width: maxWidth,
            constraints: BoxConstraints(
              maxHeight: dialogHeight,
              minHeight: minHeight, // Now guaranteed to be <= maxHeight
            ),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Color(0xFF2A3142), width: 1),
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
                // Compact header with title and close button
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF2A3142), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$year • $genre • $duration',
                              style: TextStyle(
                                color: Color(0xFF8B94A8),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Rating badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFE6B17A).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE6B17A), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Color(0xFFE6B17A), size: 14),
                            SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                color: Color(0xFFE6B17A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Brief synopsis
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      synopsis,
                      style: TextStyle(
                        color: Color(0xFF8B94A8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Quick action buttons
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF2A3142), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Add to Watchlist button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added to watchlist'),
                                backgroundColor: Color(0xFF2A3142),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFFE6B17A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_add, color: Color(0xFF0A0E1A), size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Watchlist',
                                  style: TextStyle(
                                    color: Color(0xFF0A0E1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // More info button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to full movie details page
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening full details...'),
                              backgroundColor: Color(0xFF2A3142),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A3142),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF3A4155), width: 1),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFE6B17A),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}