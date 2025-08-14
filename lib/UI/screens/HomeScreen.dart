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

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildSearchResultCard(results[index]);
      },
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2A3142), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A3142),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        item['isInWatchlist'] = !item['isInWatchlist'];
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: item['isInWatchlist']
                            ? Color(0xFFE6B17A)
                            : Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        item['isInWatchlist']
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: item['isInWatchlist']
                            ? Color(0xFF0A0E1A)
                            : Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(4), // Further reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10, // Further reduced
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1),
                  Text(
                    '${item['year']} • ${item['type']}',
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: 8, // Further reduced
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  // More robust rating layout that handles small spaces
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Color(0xFFE6B17A), size: 8),
                        SizedBox(width: 1),
                        Expanded(
                          child: Text(
                            '${item['rating']}',
                            style: TextStyle(
                              color: Color(0xFFE6B17A),
                              fontSize: 8, // Much smaller font
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // On larger screens, use a sweet spot size - not too wide, not too small
            if (constraints.maxWidth > 800) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 280, // Bigger than 200px but not full width
                    child: _buildActionCard('My Watchlist', Icons.bookmark_outline, '12 movies', 'watchlist'),
                  ),
                  SizedBox(width: 24), // Comfortable spacing
                  Container(
                    width: 280, // Same size for consistency
                    child: _buildActionCard('My Ratings', Icons.star_outline, '47 rated', 'ratings'),
                  ),
                ],
              );
            } else {
              // On smaller screens, use full width with Expanded
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Color(0xFF2A3142), width: 1),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF2A3142),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster and basic info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie poster
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Color(0xFF2A3142),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFF3A4155), width: 1),
                        ),
                      ),
                      SizedBox(width: 20),

                      // Movie details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$year • $genre',
                              style: TextStyle(
                                color: Color(0xFF8B94A8),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              duration,
                              style: TextStyle(
                                color: Color(0xFF8B94A8),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 16),

                            // Rating
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFFE6B17A).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFE6B17A), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Color(0xFFE6B17A), size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    rating.toString(),
                                    style: TextStyle(
                                      color: Color(0xFFE6B17A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '/10',
                                    style: TextStyle(
                                      color: Color(0xFFE6B17A).withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Synopsis
                  Text(
                    'Synopsis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    synopsis,
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added to watchlist'),
                                backgroundColor: Color(0xFF2A3142),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFE6B17A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_add, color: Color(0xFF0A0E1A), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Add to Watchlist',
                                  style: TextStyle(
                                    color: Color(0xFF0A0E1A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to full movie page
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A3142),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFF3A4155), width: 1),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Color(0xFFE6B17A),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}