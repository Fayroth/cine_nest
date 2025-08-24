import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/movie.dart';

class RatingDetailsSheet extends StatefulWidget {
  final Movie movie;
  final Function(double rating, String? review)? onSave;

  const RatingDetailsSheet({
    Key? key,
    required this.movie,
    this.onSave,
  }) : super(key: key);

  @override
  _RatingDetailsSheetState createState() => _RatingDetailsSheetState();
}

class _RatingDetailsSheetState extends State<RatingDetailsSheet> {
  late double currentRating;
  late TextEditingController reviewController;
  bool isEditingReview = false;

  @override
  void initState() {
    super.initState();
    currentRating = widget.movie.userRating ?? 0;
    reviewController = TextEditingController(text: widget.movie.review ?? '');
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

        double dialogHeight;
        if (isEditingReview) {
          dialogHeight = screenHeight < 700 ? screenHeight * 0.55 : screenHeight * 0.50;
        } else {
          dialogHeight = screenHeight < 700 ? screenHeight * 0.45 : screenHeight * 0.40;
        }
        dialogHeight = dialogHeight.clamp(350.0, 450.0);

        final minHeight = dialogHeight < 350 ? dialogHeight : 350.0;

        return Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: maxWidth,
            constraints: BoxConstraints(
              maxHeight: dialogHeight,
              minHeight: minHeight,
            ),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder, width: 1),
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
                _buildHeader(),
                Expanded(child: _buildContent()),
                _buildActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movie.title,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${widget.movie.year} • ${widget.movie.genre} • ${widget.movie.duration}',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  '${currentRating.toInt()}/10',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Your Rating',
                  style: TextStyle(
                    color: AppColors.accent.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Edit Rating', style: AppTextStyles.body),
          SizedBox(height: 12),
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
                            ? AppColors.accent
                            : AppColors.cardBorder,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.cardBorderLight,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$ratingValue',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.background
                                : AppColors.textSecondary,
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
          Row(
            children: [
              Text('Your Review', style: AppTextStyles.body),
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
                    color: AppColors.accent,
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isEditingReview ? AppColors.accent : AppColors.cardBorder,
                  width: 1
              ),
            ),
            child: isEditingReview
                ? TextField(
              controller: reviewController,
              maxLines: 3,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add your thoughts...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
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
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
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
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorderLight, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.button.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onSave?.call(currentRating, reviewController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rating updated'),
                    backgroundColor: AppColors.cardBorder,
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
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Save',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.background,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening full details...'),
                  backgroundColor: AppColors.cardBorder,
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
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorderLight, width: 1),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: AppColors.accent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}