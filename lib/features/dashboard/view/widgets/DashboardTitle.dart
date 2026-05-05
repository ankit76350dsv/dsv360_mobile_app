import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dsv360/core/constants/theme.dart';


class DashboardTitle extends StatelessWidget {
  const DashboardTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, d MMM').format(now);
    final customColors = Theme.of(context).custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: customColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateString,
          style: TextStyle(
            fontSize: 16,
            color: customColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
