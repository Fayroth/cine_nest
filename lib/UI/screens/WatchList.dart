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

  // Enhanced placeholder data with synopsis
  final List<Map<String, dynamic>> watchlistItems = [
    {
      'title': 'Dune: Part Two',
      'year': '2024',
      'genre': 'Sci-Fi',
      'duration': '166 min',
      'rating': 8.9,
      'type': 'Movie',
      'dateAdded': '2 days ago',
      'poster': 'placeholder',
      'synopsis': 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family. Facing a choice between the love of his life and the fate of the universe, he endeavors to prevent a terrible future.',
    },
    {
      'title': 'The Bear',
      'year': '2022',
      'genre': 'Comedy-Drama',
      'duration': 'TV Series',
      'rating': 8.7,
      'type': 'TV Show',
      'dateAdded': '1 week ago',
      'poster': 'placeholder',
      'synopsis': 'A young chef from the fine dining world returns to Chicago to run his family\'s sandwich shop after his brother\'s death, navigating staff dynamics, financial struggles, and his own grief.',
    },
    {
      'title': 'Oppenheimer',
      'year': '2023',
      'genre': 'Biography',
      'duration': '180 min',
      'rating': 8.8,
      'type': 'Movie',
      'dateAdded': '3 days ago',
      'poster': 'placeholder',
      'synopsis': 'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb during World War II, exploring the moral implications of his work.',
    },
    {
      'title': 'The Last of Us',
      'year': '2023',
      'genre': 'Drama',
      'duration': 'TV Series',
      'rating': 9.1,
      'type': 'TV Show',
      'dateAdded': '5 days ago',
      'poster': 'placeholder',
      'synopsis': 'In a post-apocalyptic world, a hardened survivor is hired to smuggle a 14-year-old girl out of an oppressive quarantine zone. What starts as a small job becomes a brutal journey across the U.S.',
    },
    {
      'title': 'Everything Everywhere All at Once',
      'year': '2022',
      'genre': 'Sci-Fi',
      'duration': '139 min',
      'rating': 8.7,
      'type': 'Movie',
      'dateAdded': '1 week ago',
      'poster': 'placeholder',
      'synopsis': 'An aging Chinese immigrant is swept up in an insane adventure where she alone can save the world by exploring other universes connecting with the lives she could have led.',
    },
    {
      'title': 'The Menu',
      'year': '2022',
      'genre': 'Thriller',
      'duration': '107 min',
      'rating': 7.2,
      'type': 'Movie',
      'dateAdded': '2 weeks ago',
      'poster': 'placeholder',
      'synopsis': 'A young couple travels to a remote island to eat at an exclusive restaurant where the chef has prepared a lavish menu, with some shocking surprises.',
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

  // New method to show item details (similar to HomeScreen)
  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemDetailsSheet(item: item),
    );
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

  // Updated with longPress gesture
  Widget _buildGridItem(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onLongPress: () => _showItemDetails(item), // Added longPress
      child: Container(
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
                    // Long press hint (subtle)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white.withOpacity(0.7), size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Hold for details',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                        Spacer(),
                        Text(
                          item['duration'],
                          style: TextStyle(
                            color: Color(0xFF8B94A8),
                            fontSize: 10,
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

  // Updated with longPress gesture
  Widget _buildListItem(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onLongPress: () => _showItemDetails(item), // Added longPress
      child: Container(
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
              child: Center(
                child: Icon(
                  Icons.touch_app,
                  color: Colors.white.withOpacity(0.3),
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

// New widget for item details (similar to HomeScreen's movie details)
class _ItemDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                  // Movie/Show poster and basic info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Color(0xFF2A3142),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFF3A4155), width: 1),
                        ),
                        child: Center(
                          child: Icon(
                            item['type'] == 'Movie' ? Icons.movie : Icons.tv,
                            color: Color(0xFF8B94A8),
                            size: 40,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${item['year']} • ${item['genre']}',
                              style: TextStyle(
                                color: Color(0xFF8B94A8),
                                fontSize: 16,
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
                                    item['rating'].toString(),
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

                  // Added to watchlist info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF0A0E1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFF2A3142), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          color: Color(0xFFE6B17A),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'In your watchlist',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Added ${item['dateAdded']}',
                                style: TextStyle(
                                  color: Color(0xFF8B94A8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                    item['synopsis'] ?? 'No synopsis available.',
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Action buttons
                  Column(
                    children: [
                      // Primary actions
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                // Mark as watched logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Marked as watched'),
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
                                    Icon(Icons.check_circle, color: Color(0xFF0A0E1A), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mark as Watched',
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
                              // Share functionality
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFF2A3142),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Color(0xFF3A4155), width: 1),
                              ),
                              child: Icon(
                                Icons.share_outlined,
                                color: Color(0xFFE6B17A),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Secondary action - Remove from watchlist
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // Remove from watchlist logic would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed from watchlist'),
                              backgroundColor: Color(0xFF2A3142),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: Color(0xFFE6B17A),
                                onPressed: () {
                                  // Undo logic
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A3142),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFF3A4155), width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Remove from Watchlist',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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