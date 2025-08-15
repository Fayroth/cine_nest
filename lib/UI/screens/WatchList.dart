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

  // Helper method to get responsive grid columns with better breakpoints
  int _getGridColumns(double screenWidth) {
    if (screenWidth < 400) return 2;        // Small phones
    if (screenWidth < 550) return 3;        // Large phones
    if (screenWidth < 750) return 4;        // Small tablets
    if (screenWidth < 950) return 5;        // Large tablets
    if (screenWidth < 1150) return 6;       // Small desktops
    if (screenWidth < 1400) return 7;       // Medium desktops
    if (screenWidth < 1700) return 8;       // Large desktops
    return 9;                               // Ultra-wide monitors
  }

  // Helper method to get maximum card width with better scaling
  double? _getMaxCardWidth(double screenWidth) {
    if (screenWidth > 1600) return 190;     // Ultra-wide screens
    if (screenWidth > 1200) return 170;     // Large screens
    if (screenWidth > 900) return 160;      // Medium screens
    return null;                            // No constraint for smaller screens
  }

  // Helper method to get responsive font sizes
  Map<String, double> _getResponsiveFontSizes(double screenWidth) {
    if (screenWidth < 400) {
      return {
        'title': 12.0,
        'subtitle': 9.0,
        'rating': 9.0,
        'duration': 8.0,
      };
    } else if (screenWidth < 600) {
      return {
        'title': 13.0,
        'subtitle': 10.0,
        'rating': 10.0,
        'duration': 8.5,
      };
    } else if (screenWidth < 900) {
      return {
        'title': 14.0,
        'subtitle': 11.0,
        'rating': 11.0,
        'duration': 9.0,
      };
    } else {
      return {
        'title': 15.0,
        'subtitle': 12.0,
        'rating': 12.0,
        'duration': 10.0,
      };
    }
  }

  // New method to show item details - simple modal approach
  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      enableDrag: true,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate optimal width for stats bar
          double statsWidth;

          if (constraints.maxWidth < 400) {
            // Small phones: Use most of available width
            statsWidth = constraints.maxWidth * 0.95;
          } else if (constraints.maxWidth < 800) {
            // Medium screens: Fixed reasonable width
            statsWidth = 360;
          } else if (constraints.maxWidth < 1200) {
            // Tablets/small desktops: Slightly larger
            statsWidth = 420;
          } else {
            // Large screens: Max width with good proportions
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
        },
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

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isGridView) {
          // Centered content on wide screens
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
          // Centered list view on wide screens
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
    final columns = _getGridColumns(screenWidth);
    final maxCardWidth = _getMaxCardWidth(screenWidth);

    return GridView.builder(
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        Widget card = _buildGridItem(filteredItems[index], index, screenWidth);

        // Apply max width constraint if needed
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
        return _buildListItem(filteredItems[index], index);
      },
    );
  }

  // Updated with better responsive design and overflow fixes
  Widget _buildGridItem(Map<String, dynamic> item, int index, double screenWidth) {
    final fontSizes = _getResponsiveFontSizes(screenWidth);

    return GestureDetector(
      onLongPress: () => _showItemDetails(item),
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
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with proper overflow handling
                    Flexible(
                      child: Text(
                        item['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizes['title']!,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 2),
                    // Subtitle with overflow protection
                    Text(
                      '${item['year']} • ${item['genre']}',
                      style: TextStyle(
                        color: Color(0xFF8B94A8),
                        fontSize: fontSizes['subtitle']!,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    // Bottom row with rating and duration
                    Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFE6B17A), size: fontSizes['rating']! + 1),
                        SizedBox(width: 2),
                        Flexible(
                          flex: 2,
                          child: Text(
                            '${item['rating']}',
                            style: TextStyle(
                              color: Color(0xFFE6B17A),
                              fontSize: fontSizes['rating']!,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          flex: 3,
                          child: Text(
                            item['duration'],
                            style: TextStyle(
                              color: Color(0xFF8B94A8),
                              fontSize: fontSizes['duration']!,
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
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.more_vert, color: Colors.white, size: 12),
      ),
      color: Color(0xFF2A3142),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'watched',
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFFE6B17A), size: 18),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Mark as Watched',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Remove from Watchlist',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_outlined, color: Color(0xFF8B94A8), size: 18),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Share',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

class _ItemDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

        // Compact height for quick action card
        double dialogHeight;
        if (screenHeight < 700) {
          dialogHeight = screenHeight * 0.48; // Very small phones
        } else if (screenHeight < 900) {
          dialogHeight = screenHeight * 0.42; // Regular phones
        } else {
          dialogHeight = 400.0; // Fixed max height for larger screens
        }

        // Fix: Ensure minHeight is never greater than maxHeight
        final minHeight = dialogHeight < 340 ? dialogHeight : 340.0;

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
                // Compact header with movie info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF2A3142), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Small poster thumbnail
                      Container(
                        width: 50,
                        height: 75,
                        decoration: BoxDecoration(
                          color: Color(0xFF2A3142),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF3A4155), width: 1),
                        ),
                        child: Center(
                          child: Icon(
                            item['type'] == 'Movie' ? Icons.movie : Icons.tv,
                            color: Color(0xFF8B94A8),
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Title and info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
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
                              '${item['year']} • ${item['genre']}',
                              style: TextStyle(
                                color: Color(0xFF8B94A8),
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              item['duration'],
                              style: TextStyle(
                                color: Color(0xFF8B94A8),
                                fontSize: 12,
                              ),
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
                              item['rating'].toString(),
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

                // Watchlist status and synopsis
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Watchlist status badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF0A0E1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF2A3142), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark,
                                color: Color(0xFFE6B17A),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Added ${item['dateAdded']}',
                                style: TextStyle(
                                  color: Color(0xFF8B94A8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        // Brief synopsis
                        Text(
                          item['synopsis'] ?? 'No synopsis available.',
                          style: TextStyle(
                            color: Color(0xFF8B94A8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                      // Mark as Watched button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Marked as watched'),
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
                                Icon(Icons.check_circle, color: Color(0xFF0A0E1A), size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Watched',
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
                      SizedBox(width: 8),
                      // Remove button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed from watchlist'),
                              backgroundColor: Color(0xFF2A3142),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
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
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A3142),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFF3A4155), width: 1),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
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