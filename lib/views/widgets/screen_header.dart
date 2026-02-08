import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconBackgroundColor;

  const ScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? customColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: customColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
