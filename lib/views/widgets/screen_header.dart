import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ScreenHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconBackgroundColor;

  const ScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconBackgroundColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.pageTitle,
          ),
        ],
      ),
    );
  }
}
