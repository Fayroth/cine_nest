import 'package:flutter/material.dart';

class SearchDiscoverScreen extends StatefulWidget {
  @override
  _SearchDiscoverScreenState createState() => _SearchDiscoverScreenState();
}

class _SearchDiscoverScreenState extends State<SearchDiscoverScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  bool isSearching = false;
  String searchQuery = '';
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'Movies', 'TV Shows', 'Action', 'Drama', 'Comedy', 'Sci-Fi', 'Horror', 'Romance', 'Thriller'];

  // Placeholder data for search results and discover sections
  final List<Map<String, dynamic>> allItems = [
    {
      'title': 'Dune: Part Two',
      'year': '2024',
      'genre': 'Sci-Fi',
      'rating': 8.9,
      'type': 'Movie',
      'isInWatchlist': false,
      'category': 'Trending',
    },
    {
      'title': 'Shogun',
      'year': '2024',
      'genre': 'Drama',
      'rating': 9.1,
      'type': 'TV Show',
      'isInWatchlist': false,
      'category': 'Trending',
    },
    {
      'title': 'The Zone of Interest',
      'year': '2023',
      'genre': 'Drama',
      'rating': 8.2,
      'type': 'Movie',
      'isInWatchlist': false,
      'category': 'Trending',
    },
    {
      'title': 'The Shawshank Redemption',
      'year': '1994',
      'genre': 'Drama',
      'rating': 9.3,
      'type': 'Movie',
      'isInWatchlist': false,
      'category': 'Top Rated',
    },
    {
      'title': 'Breaking Bad',
      'year': '2008',
      'genre': 'Crime',
      'rating': 9.5,
      'type': 'TV Show',
      'isInWatchlist': true,
      'category': 'Top Rated',
    },
    {
      'title': 'The Godfather',
      'year': '1972',
      'genre': 'Crime',
      'rating': 9.2,
      'type': 'Movie',
      'isInWatchlist': false,
      'category': 'Top Rated',
    },
    {
      'title': 'Poor Things',
      'year': '2024',
      'genre': 'Comedy',
      'rating': 8.4,
      'type': 'Movie',
      'isInWatchlist': false,
      'category': 'New Releases',
    },
    {
      'title': 'True Detective: Night Country',
      'year': '2024',
      'genre': 'Thriller',
      'rating': 8.1,
      'type': 'TV Show',
      'isInWatchlist': false,
      'category': 'New Releases',
    },
    {
      'title': 'Madame Web',
      'year': '2024',
      'genre': 'Action',
      'rating': 6.1,
      'type': 'Movie',
      'isInWatchlist': false,
      'category': 'New Releases',
    },
    {
      'title': 'The Exorcist',
      'year': '1973',
      'genre': 'Horror',
      'rating': 8.1,
      'type': 'Movie',
      'isInWatchlist': false,
      'category': 'Top Rated',
    },
    {
      'title': 'The Notebook',
      'year': '2004',
      'genre': 'Romance',
      'rating': 7.8,
      'type': 'Movie',
      'isInWatchlist': false,
      'category': 'Top Rated',
    },
  ];

  List<Map<String, dynamic>> get trendingItems =>
      allItems.where((item) => item['category'] == 'Trending').toList();

  List<Map<String, dynamic>> get topRatedItems =>
      allItems.where((item) => item['category'] == 'Top Rated').toList();

  List<Map<String, dynamic>> get newReleasesItems =>
      allItems.where((item) => item['category'] == 'New Releases').toList();

  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchQuery = query;

      // Filter based on search query and selected category
      searchResults = allItems.where((item) {
        final matchesQuery = item['title'].toString().toLowerCase().contains(query.toLowerCase());
        final matchesCategory = selectedCategory == 'All' ||
            item['type'] == selectedCategory ||
            item['genre'] == selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  List<Map<String, dynamic>> _getFilteredItems(List<Map<String, dynamic>> items) {
    if (selectedCategory == 'All') return items;

    return items.where((item) {
      return item['type'] == selectedCategory || item['genre'] == selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E1A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildSearchHeader(),
                _buildCategories(),
                Expanded(
                  child: isSearching ? _buildSearchResults() : _buildDiscoverContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
                      controller: _searchController,
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
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
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

  Widget _buildCategories() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
                if (isSearching) {
                  _performSearch(searchQuery);
                }
              });
            },
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
                category,
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

  Widget _buildDiscoverContent() {
    final filteredTrending = _getFilteredItems(trendingItems);
    final filteredTopRated = _getFilteredItems(topRatedItems);
    final filteredNewReleases = _getFilteredItems(newReleasesItems);

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 20)),
        if (filteredTrending.isNotEmpty) ...[
          _buildSection('Trending Now', filteredTrending),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
        if (filteredTopRated.isNotEmpty) ...[
          _buildSection('Top Rated', filteredTopRated),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
        if (filteredNewReleases.isNotEmpty) ...[
          _buildSection('New Releases', filteredNewReleases),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
        _buildGenresSection(),
        SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItemCard(items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2A3142),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF3A4155), width: 1),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        item['isInWatchlist'] = !item['isInWatchlist'];
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              item['isInWatchlist']
                                  ? 'Added to watchlist'
                                  : 'Removed from watchlist'
                          ),
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
                      padding: EdgeInsets.all(8),
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
                Positioned(
                  bottom: 8,
                  left: 8,
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
                        SizedBox(width: 4),
                        Text(
                          '${item['rating']}',
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
          SizedBox(height: 8),
          Text(
            item['title'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            '${item['year']} • ${item['type']}',
            style: TextStyle(
              color: Color(0xFF8B94A8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresSection() {
    final genres = [
      {'name': 'Action', 'icon': Icons.sports_martial_arts, 'color': Color(0xFFFF6B6B)},
      {'name': 'Comedy', 'icon': Icons.mood, 'color': Color(0xFF4ECDC4)},
      {'name': 'Drama', 'icon': Icons.theater_comedy, 'color': Color(0xFF95E1D3)},
      {'name': 'Horror', 'icon': Icons.nightlight_round, 'color': Color(0xFF8B5CF6)},
      {'name': 'Sci-Fi', 'icon': Icons.rocket_launch, 'color': Color(0xFF7B68EE)},
      {'name': 'Romance', 'icon': Icons.favorite, 'color': Color(0xFFFF6B9D)},
      {'name': 'Thriller', 'icon': Icons.psychology, 'color': Color(0xFFF59E0B)},
      {'name': 'Crime', 'icon': Icons.gavel, 'color': Color(0xFFEF4444)},
      {'name': 'Documentary', 'icon': Icons.movie_filter, 'color': Color(0xFF10B981)},
    ];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Browse by Genre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = selectedCategory == genre['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = genre['name'] as String;
                    });

                    // Scroll to top to show filtered results
                    if (context.findRenderObject() != null) {
                      Scrollable.of(context).position.animateTo(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
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
                          size: isSelected ? 32 : 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          genre['name'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return _buildEmptySearchState();
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultItem(searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF2A3142), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFF2A3142),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  '${item['year']} • ${item['genre']} • ${item['type']}',
                  style: TextStyle(
                    color: Color(0xFF8B94A8),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6B17A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFE6B17A), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Color(0xFFE6B17A), size: 14),
                          SizedBox(width: 4),
                          Text(
                            '${item['rating']}',
                            style: TextStyle(
                              color: Color(0xFFE6B17A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          item['isInWatchlist'] = !item['isInWatchlist'];
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                item['isInWatchlist']
                                    ? 'Added to watchlist'
                                    : 'Removed from watchlist'
                            ),
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
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: item['isInWatchlist']
                              ? Color(0xFFE6B17A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item['isInWatchlist']
                                ? Color(0xFFE6B17A)
                                : Color(0xFF2A3142),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item['isInWatchlist']
                                  ? Icons.check
                                  : Icons.add,
                              color: item['isInWatchlist']
                                  ? Color(0xFF0A0E1A)
                                  : Color(0xFFE6B17A),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              item['isInWatchlist']
                                  ? 'Added'
                                  : 'Watchlist',
                              style: TextStyle(
                                color: item['isInWatchlist']
                                    ? Color(0xFF0A0E1A)
                                    : Color(0xFFE6B17A),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFF2A3142), width: 1),
            ),
            child: Icon(
              Icons.search_off,
              color: Color(0xFF8B94A8),
              size: 48,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No results found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching with different keywords\nor browse our categories',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8B94A8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}