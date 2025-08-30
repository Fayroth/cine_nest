import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/di/injection_container.dart' as di;
import '../../data/repositories/movie_repository.dart';
import '../../data/models/movie.dart';

class ApiTestScreen extends ConsumerStatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends ConsumerState<ApiTestScreen> {
  final MovieRepository _movieRepository = di.sl<MovieRepository>();

  bool _isLoading = false;
  String _status = 'Ready to test API';
  List<Movie> _movies = [];
  String? _error;

  Future<void> _testTrendingMovies() async {
    setState(() {
      _isLoading = true;
      _status = 'Fetching trending movies...';
      _error = null;
      _movies = [];
    });

    final result = await _movieRepository.getTrending(page: 1);

    result.fold(
          (failure) {
        setState(() {
          _isLoading = false;
          _status = 'Error occurred';
          _error = failure.message;
        });
      },
          (movies) {
        setState(() {
          _isLoading = false;
          _status = 'Success! Found ${movies.length} trending items';
          _movies = movies;
        });
      },
    );
  }

  Future<void> _testPopularMovies() async {
    setState(() {
      _isLoading = true;
      _status = 'Fetching popular movies...';
      _error = null;
      _movies = [];
    });

    final result = await _movieRepository.getPopularMovies(page: 1);

    result.fold(
          (failure) {
        setState(() {
          _isLoading = false;
          _status = 'Error occurred';
          _error = failure.message;
        });
      },
          (movies) {
        setState(() {
          _isLoading = false;
          _status = 'Success! Found ${movies.length} popular movies';
          _movies = movies;
        });
      },
    );
  }

  Future<void> _testSearch(String query) async {
    setState(() {
      _isLoading = true;
      _status = 'Searching for "$query"...';
      _error = null;
      _movies = [];
    });

    final result = await _movieRepository.searchMulti(query: query);

    result.fold(
          (failure) {
        setState(() {
          _isLoading = false;
          _status = 'Error occurred';
          _error = failure.message;
        });
      },
          (movies) {
        setState(() {
          _isLoading = false;
          _status = 'Found ${movies.length} results for "$query"';
          _movies = movies;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('API Test', style: AppTextStyles.h1),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status Container
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _error != null ? AppColors.error : AppColors.cardBorder,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status:', style: AppTextStyles.bodyLarge),
                SizedBox(height: 8),
                if (_isLoading)
                  CircularProgressIndicator(color: AppColors.accent)
                else
                  Text(
                    _status,
                    style: TextStyle(
                      color: _error != null ? AppColors.error : AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (_error != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Error: $_error',
                    style: TextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),

          // Test Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildTestButton(
                  'Test Trending Movies',
                  Icons.trending_up,
                  _testTrendingMovies,
                ),
                SizedBox(height: 12),
                _buildTestButton(
                  'Test Popular Movies',
                  Icons.star,
                  _testPopularMovies,
                ),
                SizedBox(height: 12),
                _buildTestButton(
                  'Test Search (Batman)',
                  Icons.search,
                      () => _testSearch('Batman'),
                ),
              ],
            ),
          ),

          // Results
          if (_movies.isNotEmpty) ...[
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Results (showing first 5):',
                style: AppTextStyles.h3,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: _movies.length > 5 ? 5 : _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                movie.title,
                                style: AppTextStyles.bodyLarge,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                movie.type == ContentType.movie ? 'Movie' : 'TV',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${movie.year} • ${movie.genre} • ⭐ ${movie.rating}',
                          style: AppTextStyles.label,
                        ),
                        if (movie.synopsis != null) ...[
                          SizedBox(height: 8),
                          Text(
                            movie.synopsis!,
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (movie.posterUrl != null) ...[
                          SizedBox(height: 8),
                          Text(
                            'Has poster: ✅',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isLoading
              ? AppColors.cardBorder
              : AppColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.background,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.background,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}