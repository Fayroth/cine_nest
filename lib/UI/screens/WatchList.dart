import 'package:flutter/material.dart';

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

  // Placeholder data
  final List<Map<String, dynamic>> watchlistItems = [
    {
      'title': 'Dune: Part Two',
      'year': '2024',
      'genre': 'Sci-Fi',
      'duration': '166 min',
      'rating': 8.9,
      'type': 'Movie',
      'dateAdded': '2 days ago',
      'poster': 'placeholder'
    },
    {
      'title': 'The Bear',
      'year': '2022',
      'genre': 'Comedy-Drama',
      'duration': 'TV Series',
      'rating': 8.7,
      'type': 'TV Show',
      'dateAdded': '1 week ago',
      'poster': 'placeholder'
    },
    {
      'title': 'Oppenheimer',
      'year': '2023',
      'genre': 'Biography',
      'duration': '180 min',
      'rating': 8.8,
      'type': 'Movie',
      'dateAdded': '3 days ago',
      'poster': 'placeholder'
    },
    {
      'title': 'The Last of Us',
      'year': '2023',
      'genre': 'Drama',
      'duration': 'TV Series',
      'rating': 9.1,
      'type': 'TV Show',
      'dateAdded': '5 days ago',
      'poster': 'placeholder'
    },
    {
      'title': 'Everything Everywhere All at Once',
      'year': '2022',
      'genre': 'Sci-Fi',
      'duration': '139 min',
      'rating': 8.7,
      'type': 'Movie',
      'dateAdded': '1 week ago',
      'poster': 'placeholder'
    },
    {
      'title': 'The Menu',
      'year': '2022',
      'genre': 'Thriller',
      'duration': '107 min',
      'rating': 7.2,
      'type': 'Movie',
      'dateAdded': '2 weeks ago',
      'poster': 'placeholder'
    },
  ];

  // Cache filtered items to avoid rebuilding
  List<Map<String, dynamic>>? _cachedFilteredItems;
  String? _lastFilter;

  @override
  void initState() {
    super.initState();

    // Reduced animation duration for faster feel
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400), // Reduced from 800ms
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic), // Better curve
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1), // Reduced from 0.3 for subtler animation
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    // Start animation immediately without waiting for post frame callback
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredItems {
    // Cache filtered results to avoid repeated filtering
    if (_lastFilter != selectedFilter || _cachedFilteredItems == null) {
      _lastFilter = selectedFilter;

      if (selectedFilter == 'All') {
        _cachedFilteredItems = watchlistItems;
      } else if (selectedFilter == 'Movies') {
        _cachedFilteredItems = watchlistItems.where((item) => item['type'] == 'Movie').toList();
      } else if (selectedFilter == 'TV Shows') {
        _cachedFilteredItems = watchlistItems.where((item) => item['type'] == 'TV Show').toList();
      } else if (selectedFilter == 'Recently Added') {
        _cachedFilteredItems = List.from(watchlistItems)..sort((a, b) => a['dateAdded'].compareTo(b['dateAdded']));
      } else {
        _cachedFilteredItems = watchlistItems;
      }
    }

    return _cachedFilteredItems!;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Watchlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${filteredItems.length} items to watch',
                  style: TextStyle(
                    color: Color(0xFF8B94A8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF2A3142), width: 1),
              ),
              child: Icon(
                isGridView ? Icons.view_list : Icons.grid_view,
                color: Color(0xFFE6B17A),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final movieCount = watchlistItems.where((item) => item['type'] == 'Movie').length;
    final tvShowCount = watchlistItems.where((item) => item['type'] == 'TV Show').length;
    final totalHours = movieCount * 2.5 + tvShowCount * 10; // Rough estimate

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6B17A).withOpacity(0.1),
              Color(0xFFE6B17A).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFE6B17A).withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem('${watchlistItems.length}', 'Total Items', Icons.bookmark),
            ),
            Container(
              width: 1,
              height: 40,
              color: Color(0xFF2A3142),
            ),
            Expanded(
              child: _buildStatItem('${totalHours.toInt()}h', 'Watch Time', Icons.access_time),
            ),
            Container(
              width: 1,
              height: 40,
              color: Color(0xFF2A3142),
            ),
            Expanded(
              child: _buildStatItem('$movieCount', 'Movies', Icons.movie),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFFE6B17A), size: 20),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF8B94A8),
            fontSize: 12,
          ),
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
                  color: isSelected ? Color(0xFFE6B17A) : Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Color(0xFFE6B17A) : Color(0xFF2A3142),
                    width: 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Color(0xFF0A0E1A) : Colors.white,
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
      return _buildEmptyState();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return _buildGridItem(filteredItems[index], index);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return _buildListItem(filteredItems[index], index);
      },
    );
  }

  // Add index parameter for potential future staggered animations
  Widget _buildGridItem(Map<String, dynamic> item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF2A3142), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF2A3142),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildActionMenu(item),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${item['year']} • ${item['genre']}',
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: 12,
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFE6B17A), size: 14),
                      SizedBox(width: 2),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item, int index) {
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
                  '${item['year']} • ${item['genre']}',
                  style: TextStyle(
                    color: Color(0xFF8B94A8),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item['duration'],
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
                    Text(
                      'Added ${item['dateAdded']}',
                      style: TextStyle(
                        color: Color(0xFF8B94A8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          _buildActionMenu(item),
        ],
      ),
    );
  }

  Widget _buildActionMenu(Map<String, dynamic> item) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.more_vert, color: Colors.white, size: 16),
      ),
      color: Color(0xFF2A3142),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'watched',
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFFE6B17A), size: 20),
              SizedBox(width: 12),
              Text('Mark as Watched', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Remove from Watchlist', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_outlined, color: Color(0xFF8B94A8), size: 20),
              SizedBox(width: 12),
              Text('Share', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        _handleMenuAction(value, item);
      },
    );
  }

  Widget _buildEmptyState() {
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
              Icons.bookmark_outline,
              color: Color(0xFFE6B17A),
              size: 48,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Your watchlist is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start adding movies and shows\nyou want to watch later',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8B94A8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFE6B17A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Explore Movies',
                style: TextStyle(
                  color: Color(0xFF0A0E1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'watched':
        _showWatchedDialog(item);
        break;
      case 'remove':
        _removeFromWatchlist(item);
        break;
      case 'share':
        _shareItem(item);
        break;
    }
  }

  void _showWatchedDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mark as Watched',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Did you enjoy "${item['title']}"? You can rate it now!',
          style: TextStyle(color: Color(0xFF8B94A8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: Color(0xFF8B94A8))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to rating screen
            },
            child: Text('Rate Now', style: TextStyle(color: Color(0xFFE6B17A))),
          ),
        ],
      ),
    );
  }

  void _removeFromWatchlist(Map<String, dynamic> item) {
    setState(() {
      watchlistItems.removeWhere((element) => element['title'] == item['title']);
      _cachedFilteredItems = null; // Clear cache when data changes
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from watchlist'),
        backgroundColor: Color(0xFF2A3142),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Color(0xFFE6B17A),
          onPressed: () {
            setState(() {
              watchlistItems.add(item);
              _cachedFilteredItems = null; // Clear cache when data changes
            });
          },
        ),
      ),
    );
  }

  void _shareItem(Map<String, dynamic> item) {
    // Handle sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${item['title']}"'),
        backgroundColor: Color(0xFF2A3142),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}