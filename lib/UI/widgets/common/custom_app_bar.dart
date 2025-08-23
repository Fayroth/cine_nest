import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final bool showBack;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.onBackPressed,
    this.trailing,
    this.showBack = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          if (showBack) SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.h1),
                if (subtitle != null)
                  Text(subtitle!, style: AppTextStyles.label),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}