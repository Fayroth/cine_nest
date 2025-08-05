import 'package:flutter/material.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _searchController;
  late AnimationController _backButtonController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchAnimation;
  late Animation<double> _backButtonAnimation;
  late Animation<double> _blurAnimation;

  late TextEditingController _searchTextController;
  late FocusNode _searchFocusNode;

  bool isSearchActive = false;
  String searchQuery = '';
  String selectedGenre = 'All';
  List<Map<String, dynamic>> searchResults = [];

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

  // Sample movie data for search/genre filtering
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

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: Duration(milliseconds: 600), // Longer for smoother expansion
      vsync: this,
    );
    _backButtonController = AnimationController(
      duration: Duration(milliseconds: 300), // Quick appear animation
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.easeInOutCubic), // Smooth expansion
    );

    _backButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backButtonController, curve: Curves.easeOutBack), // Bouncy appear
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.easeInOutQuart),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _backButtonController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    if (isSearchActive == !isSearchActive) return; // Safety check

    setState(() {
      isSearchActive = !isSearchActive;
    });

    if (isSearchActive) {
      _searchController.forward();
      // Show back button after a delay (when search bar expansion is mostly complete)
      Future.delayed(Duration(milliseconds: 400), () {
        if (isSearchActive && mounted) {
          _backButtonController.forward();
        }
      });

      Future.delayed(Duration(milliseconds: 600), () {
        if (isSearchActive && mounted) {
          _searchFocusNode.requestFocus();
        }
      });

      // Initialize search results based on current genre selection
      _performSearch(_searchTextController.text);
    } else {
      _backButtonController.reset(); // Reset instead of reverse for better performance
      _searchController.reverse();
      _searchTextController.clear();
      searchResults.clear();
      selectedGenre = 'All';
      _searchFocusNode.unfocus();
    }
  }

  void _performSearch(String query) {
    // Debounce search to avoid excessive rebuilds
    if (searchQuery == query) return;

    setState(() {
      searchQuery = query;
      // Always show results based on current filters and search
      searchResults = allMovies.where((movie) {
        final matchesQuery = query.isEmpty || movie['title'].toString().toLowerCase().contains(query.toLowerCase());
        final matchesGenre = selectedGenre == 'All' || movie['genre'] == selectedGenre;
        return matchesQuery && matchesGenre;
      }).toList();
    });
  }

  void _selectGenre(String genre) {
    if (selectedGenre == genre) return; // Prevent unnecessary rebuilds

    setState(() {
      selectedGenre = genre;
    });
    _performSearch(_searchTextController.text); // Trigger search with current query
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Main blurred content
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _blurAnimation,
                builder: (context, child) {
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: CustomScrollView(
                          physics: BouncingScrollPhysics(),
                          slivers: [
                            // App bar placeholder to maintain spacing
                            SliverToBoxAdapter(
                              child: SizedBox(height: 80), // Space for floating search bar
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 12)),
                            _buildGenreCarousel(),
                            SliverToBoxAdapter(child: SizedBox(height: 16)),
                            _buildFeaturedSection(),
                            SliverToBoxAdapter(child: SizedBox(height: 32)),
                            _buildQuickActions(),
                            SliverToBoxAdapter(child: SizedBox(height: 32)),
                            _buildRecentlyWatched(),
                            SliverToBoxAdapter(child: SizedBox(height: 32)),
                            _buildYourRatings(),
                            SliverToBoxAdapter(child: SizedBox(height: 32)),
                            _buildTrendingSection(),
                            SliverToBoxAdapter(child: SizedBox(height: 100)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Floating search bar - always on top
            RepaintBoundary(
              child: Container(
                color: Color(0xFF0A0E1A),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Back button - appears after animation
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _backButtonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _backButtonAnimation.value,
                            child: Container(
                              width: _backButtonAnimation.value > 0 ? 48 : 0,
                              height: 48,
                              margin: EdgeInsets.only(right: _backButtonAnimation.value > 0 ? 12 : 0),
                              child: _backButtonAnimation.value > 0
                                  ? GestureDetector(
                                onTap: _toggleSearch,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1A1F2E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Color(0xFF2A3142), width: 1),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    // Title section - fades when search is active
                    if (!isSearchActive)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Color(0xFF8B94A8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'CineNest',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Search bar - starts from right, expands left
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _searchAnimation,
                        builder: (context, child) {
                          final buttonWidth = 48.0;
                          final screenWidth = MediaQuery.of(context).size.width;
                          final backButtonSpace = _backButtonAnimation.value > 0 ? 60.0 : 0.0;
                          final titleSpace = isSearchActive ? 0.0 : 120.0; // Space for title when visible
                          final maxWidth = screenWidth - 40 - backButtonSpace - titleSpace; // Account for padding
                          final currentWidth = buttonWidth + ((maxWidth - buttonWidth) * _searchAnimation.value);

                          return Container(
                            width: currentWidth,
                            height: 48,
                            child: GestureDetector(
                              onTap: isSearchActive ? null : _toggleSearch,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF1A1F2E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Color(0xFF2A3142), width: 1),
                                ),
                                child: _searchAnimation.value < 0.3
                                    ? Center(
                                  child: Icon(
                                    Icons.search,
                                    color: Color(0xFFE6B17A),
                                    size: 24,
                                  ),
                                )
                                    : Padding(
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
                                      if (_searchTextController.text.isNotEmpty)
                                        GestureDetector(
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search overlay - positioned below search bar
            _buildSearchOverlay(),
          ],
        ),
      ),
    );
  }





  Widget _buildGenreCarousel() {
    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Container(
          height: 65, // Smaller height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: genres.length, // Show all genres
            itemBuilder: (context, index) {
              final genre = genres[index];
              return RepaintBoundary(
                child: _buildGenreCard(genre),
              );
            },
          ),
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
          _toggleSearch(); // Open search overlay with selected genre
        }
        _selectGenre(genre['name']);
      },
      child: Container(
        width: 80, // 15% longer than original 70
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
              size: 20, // Slightly smaller for the reduced height
            ),
            SizedBox(height: 6),
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
    if (!isSearchActive) return SizedBox.shrink();

    return Positioned(
      top: 80, // Position below the floating search bar
      left: 0,
      right: 0,
      bottom: 0,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _searchAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -30 * (1 - _searchAnimation.value)),
              child: Transform.scale(
                scale: 0.95 + (0.05 * _searchAnimation.value),
                child: Opacity(
                  opacity: _searchAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF0A0E1A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border.all(color: Color(0xFF2A3142), width: 1),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        // Genre carousel
                        RepaintBoundary(
                          child: Container(
                            height: 65,
                            child: ListView.builder(
                              key: ValueKey('search_genre_carousel'), // Prevent rebuilds
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              itemCount: genres.length,
                              itemBuilder: (context, index) {
                                final genre = genres[index];
                                return RepaintBoundary(
                                  key: ValueKey('search_${genre['name']}'), // Unique key
                                  child: _buildGenreCard(genre),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: RepaintBoundary(
                            child: _buildSearchResults(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Color(0xFF0A0E1A),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleSearch,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1A1F2E),
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
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF2A3142), width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Color(0xFF8B94A8),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
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
                      ),
                    ),
                  ),
                  if (_searchTextController.text.isNotEmpty)
                    GestureDetector(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchGenreFilters() {
    return Container(
      color: Color(0xFF0A0E1A),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = selectedGenre == genre['name'];

          return GestureDetector(
            onTap: () => _selectGenre(genre['name']),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFE6B17A) : Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Color(0xFFE6B17A) : Color(0xFF2A3142),
                  width: 1,
                ),
              ),
              child: Text(
                genre['name'],
                style: TextStyle(
                  color: isSelected ? Color(0xFF0A0E1A) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    // If no search has been performed yet, show results based on selected genre
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
      key: ValueKey('search_results_${results.length}'), // Prevent unnecessary rebuilds
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey(results[index]['title']), // Unique key for each item
          child: _buildSearchResultCard(results[index]),
        );
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
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${item['year']} • ${item['type']}',
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: 10,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Color(0xFFE6B17A), size: 10),
                      SizedBox(width: 2),
                      Text(
                        '${item['rating']}',
                        style: TextStyle(
                          color: Color(0xFFE6B17A),
                          fontSize: 10,
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

  // Keep all the existing methods from the original HomeScreen
  Widget _buildFeaturedSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 240,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.85),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: _buildFeaturedCard(index),
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
        child: Row(
          children: [
            Expanded(child: _buildActionCard('My Watchlist', Icons.bookmark_outline, '12 movies','watchlist'), ),
            SizedBox(width: 16),
            Expanded(child: _buildActionCard('My Ratings', Icons.star_outline, '47 rated','ratings')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, String subtitle, String destination) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/$destination');},
        child:
        Container(
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
        )
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
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildMovieCard(index, isSmall: true, showRating: true);
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

  Widget _buildMovieCard(int index, {bool isSmall = false, bool showRating = false}) {
    final titles = ['Interstellar', 'Inception', 'The Dark Knight', 'Pulp Fiction', 'Fight Club'];
    final ratings = [9.2, 9.0, 8.8, 8.9, 8.7];

    return Container(
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
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Color(0xFF2A3142),
                    ),
                  ),
                  if (showRating)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Color(0xFFE6B17A), size: 12),
                            SizedBox(width: 2),
                            Text(
                              '${ratings[index]}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
        ],
      ),
    );
  }
}