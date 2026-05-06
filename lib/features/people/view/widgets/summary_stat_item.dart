import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class SummaryStatItem extends StatelessWidget {
  final String title;
  final String value;
  final String employees;

  const SummaryStatItem({
    super.key,
    required this.title,
    required this.value,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: customColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: customColors.greyBorder!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: customColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: customColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            employees,
            style: TextStyle(
              fontSize: 11,
              color: customColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
