import 'package:flutter/material.dart';

class RatingsScreen extends StatefulWidget {
  @override
  _RatingsScreenState createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedSort = 'Recent';
  String selectedFilter = 'All';
  bool isEditMode = false;

  final List<String> sortOptions = ['Recent', 'Highest', 'Lowest', 'Title'];
  final List<String> filterOptions = ['All', '10/10', '9+', '8+', '7+', 'Movies', 'TV Shows'];

  // Placeholder data for rated items
  final List<Map<String, dynamic>> ratedItems = [
    {
      'title': 'Interstellar',
      'year': '2014',
      'genre': 'Sci-Fi',
      'duration': '169 min',
      'rating': 5,
      'userRating': 10,
      'type': 'Movie',
      'dateRated': '2 days ago',
      'review': 'A masterpiece of science fiction cinema. Nolan at his best!',
    },
    {
      'title': 'Breaking Bad',
      'year': '2008',
      'genre': 'Crime Drama',
      'duration': 'TV Series',
      'rating': 9.5,
      'userRating': 10,
      'type': 'TV Show',
      'dateRated': '1 week ago',
      'review': 'The best TV show ever made. Period.',
    },
    {
      'title': 'The Dark Knight',
      'year': '2008',
      'genre': 'Action',
      'duration': '152 min',
      'rating': 9.0,
      'userRating': 9,
      'type': 'Movie',
      'dateRated': '3 weeks ago',
      'review': 'Heath Ledger\'s performance is legendary',
    },
    {
      'title': 'Inception',
      'year': '2010',
      'genre': 'Sci-Fi',
      'duration': '148 min',
      'rating': 8.8,
      'userRating': 9,
      'type': 'Movie',
      'dateRated': '1 month ago',
      'review': null,
    },
    {
      'title': 'The Last of Us',
      'year': '2023',
      'genre': 'Drama',
      'duration': 'TV Series',
      'rating': 9.1,
      'userRating': 8,
      'type': 'TV Show',
      'dateRated': '2 months ago',
      'review': 'Excellent adaptation, captures the essence of the game',
    },
    {
      'title': 'Pulp Fiction',
      'year': '1994',
      'genre': 'Crime',
      'duration': '154 min',
      'rating': 8.9,
      'userRating': 7,
      'type': 'Movie',
      'dateRated': '3 months ago',
      'review': null,
    },
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

  List<Map<String, dynamic>> get filteredAndSortedItems {
    var filtered = List<Map<String, dynamic>>.from(ratedItems);

    // Apply filter
    switch (selectedFilter) {
      case '10/10':
        filtered = filtered.where((item) => item['userRating'] == 10).toList();
        break;
      case '9+':
        filtered = filtered.where((item) => item['userRating'] >= 9).toList();
        break;
      case '8+':
        filtered = filtered.where((item) => item['userRating'] >= 8).toList();
        break;
      case '7+':
        filtered = filtered.where((item) => item['userRating'] >= 7).toList();
        break;
      case 'Movies':
        filtered = filtered.where((item) => item['type'] == 'Movie').toList();
        break;
      case 'TV Shows':
        filtered = filtered.where((item) => item['type'] == 'TV Show').toList();
        break;
    }

    // Apply sort
    switch (selectedSort) {
      case 'Highest':
        filtered.sort((a, b) => b['userRating'].compareTo(a['userRating']));
        break;
      case 'Lowest':
        filtered.sort((a, b) => a['userRating'].compareTo(b['userRating']));
        break;
      case 'Title':
        filtered.sort((a, b) => a['title'].compareTo(b['title']));
        break;
      case 'Recent':
      default:
      // Already sorted by recent
        break;
    }

    return filtered;
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
                _buildCompactStats(),
                _buildFilters(),
                Expanded(child: _buildRatingsList()),
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
                  'My Ratings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${filteredAndSortedItems.length} items rated',
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
                isEditMode = !isEditMode;
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEditMode ? Color(0xFFE6B17A) : Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEditMode ? Color(0xFFE6B17A) : Color(0xFF2A3142),
                  width: 1,
                ),
              ),
              child: Icon(
                isEditMode ? Icons.check : Icons.edit_outlined,
                color: isEditMode ? Color(0xFF0A0E1A) : Color(0xFFE6B17A),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStats() {
    final totalRatings = ratedItems.length;
    final perfectScoreCount = ratedItems.where((item) => item['userRating'] == 10).length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF2A3142), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter, color: Color(0xFF8B94A8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '$totalRatings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Rated',
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE6B17A).withOpacity(0.2),
                    Color(0xFFE6B17A).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFE6B17A).withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Color(0xFFE6B17A), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '$perfectScoreCount',
                    style: TextStyle(
                      color: Color(0xFFE6B17A),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Perfect 10s',
                    style: TextStyle(
                      color: Color(0xFFE6B17A).withOpacity(0.8),
                      fontSize: 14,
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

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildCustomDropdown(
              selectedSort,
              sortOptions,
                  (value) => setState(() => selectedSort = value),
              'Sort',
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildCustomDropdown(
              selectedFilter,
              filterOptions,
                  (value) => setState(() => selectedFilter = value),
              'Filter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDropdown(String value, List<String> items, Function(String) onChanged, String hint) {
    return GestureDetector(
      onTap: () {
        _showCustomDropdown(context, value, items, onChanged);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF2A3142), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hint,
                  style: TextStyle(
                    color: Color(0xFF8B94A8),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Color(0xFFE6B17A), size: 24),
          ],
        ),
      ),
    );
  }

  void _showCustomDropdown(BuildContext context, String currentValue, List<String> items, Function(String) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF2A3142), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF2A3142),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...items.map((item) {
              final isSelected = item == currentValue;
              return GestureDetector(
                onTap: () {
                  onChanged(item);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFE6B17A).withOpacity(0.1) : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? Color(0xFFE6B17A) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? Color(0xFFE6B17A) : Colors.white,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsList() {
    final items = filteredAndSortedItems;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildRatingItem(items[index], index);
      },
    );
  }

  Widget _buildRatingItem(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () => _showRatingDetails(item),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF2A3142), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF2A3142),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  if (isEditMode)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isEditMode) _buildStarRating(item['userRating']),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${item['year']} • ${item['genre']} • ${item['duration']}',
                    style: TextStyle(
                      color: Color(0xFF8B94A8),
                      fontSize: 14,
                    ),
                  ),
                  if (item['review'] != null) ...[
                    SizedBox(height: 12),
                    Text(
                      item['review'],
                      style: TextStyle(
                        color: Color(0xFF8B94A8),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8),
                  Text(
                    'Rated ${item['dateRated']}',
                    style: TextStyle(
                      color: Color(0xFF8B94A8).withOpacity(0.7),
                      fontSize: 12,
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

  Widget _buildStarRating(num rating) {
    // Convert 10-point scale to 5 stars for visual display
    final starRating = rating / 2;
    final fullStars = starRating.floor();
    final hasHalfStar = starRating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < fullStars) {
            return Icon(Icons.star, color: Color(0xFFE6B17A), size: 16);
          } else if (index == fullStars && hasHalfStar) {
            return Icon(Icons.star_half, color: Color(0xFFE6B17A), size: 16);
          } else {
            return Icon(Icons.star_outline, color: Color(0xFF2A3142), size: 16);
          }
        }),
        SizedBox(width: 4),
        Text(
          '${rating.toStringAsFixed(rating % 1 == 0 ? 0 : 1)}',
          style: TextStyle(
            color: Color(0xFFE6B17A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
              Icons.star_outline,
              color: Color(0xFFE6B17A),
              size: 48,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No ratings yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start rating movies and shows\nto build your collection',
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
                'Discover Movies',
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

  void _showRatingDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RatingDetailsSheet(item: item),
    );
  }
}

class _RatingDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> item;

  _RatingDetailsSheet({required this.item});

  @override
  _RatingDetailsSheetState createState() => _RatingDetailsSheetState();
}

class _RatingDetailsSheetState extends State<_RatingDetailsSheet> {
  late double currentRating;
  late TextEditingController reviewController;
  bool isEditingReview = false;

  @override
  void initState() {
    super.initState();
    currentRating = widget.item['userRating'].toDouble();
    reviewController = TextEditingController(text: widget.item['review'] ?? '');
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

        // Compact height for quick edit card
        double dialogHeight;
        if (isEditingReview) {
          // Slightly taller when editing review
          dialogHeight = screenHeight < 700 ? screenHeight * 0.55 : screenHeight * 0.50;
        } else {
          dialogHeight = screenHeight < 700 ? screenHeight * 0.45 : screenHeight * 0.40;
        }
        dialogHeight = dialogHeight.clamp(350.0, 450.0); // Min and max constraints

        // Fix: Ensure minHeight is never greater than maxHeight
        final minHeight = dialogHeight < 350 ? dialogHeight : 350.0;

        return Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
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
                // Compact header
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
                              widget.item['title'],
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
                              '${widget.item['year']} • ${widget.item['genre']} • ${widget.item['duration']}',
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
                      // Current rating display
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFFE6B17A).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE6B17A), width: 1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${currentRating.toInt()}/10',
                              style: TextStyle(
                                color: Color(0xFFE6B17A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Your Rating',
                              style: TextStyle(
                                color: Color(0xFFE6B17A).withOpacity(0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating selector and review
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Compact rating selector with circular buttons
                        Text(
                          'Quick Edit Rating',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        // Single row of circular rating buttons
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(10, (index) {
                                final ratingValue = index + 1;
                                final isSelected = ratingValue <= currentRating;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentRating = ratingValue.toDouble();
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 3),
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Color(0xFFE6B17A)
                                          : Color(0xFF2A3142),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Color(0xFFE6B17A)
                                            : Color(0xFF3A4155),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$ratingValue',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Color(0xFF0A0E1A)
                                              : Color(0xFF8B94A8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Compact review section
                        Row(
                          children: [
                            Text(
                              'Your Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isEditingReview = !isEditingReview;
                                });
                              },
                              child: Text(
                                isEditingReview ? 'Done' : 'Edit',
                                style: TextStyle(
                                  color: Color(0xFFE6B17A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF0A0E1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isEditingReview ? Color(0xFFE6B17A) : Color(0xFF2A3142),
                                width: 1
                            ),
                          ),
                          child: isEditingReview
                              ? TextField(
                            controller: reviewController,
                            maxLines: 3,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Add your thoughts...',
                              hintStyle: TextStyle(color: Color(0xFF8B94A8)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          )
                              : Text(
                            reviewController.text.isEmpty
                                ? 'No review yet. Tap Edit to add one.'
                                : reviewController.text,
                            style: TextStyle(
                              color: reviewController.text.isEmpty
                                  ? Color(0xFF8B94A8)
                                  : Colors.white,
                              fontSize: 14,
                              fontStyle: reviewController.text.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF2A3142), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF2A3142),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF3A4155), width: 1),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Save button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Rating updated'),
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
                            child: Center(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Color(0xFF0A0E1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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