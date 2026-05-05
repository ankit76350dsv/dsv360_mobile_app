import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class TimeBox extends StatelessWidget {
  final int value;
  final String label;

  const TimeBox({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: customColors.textSecondary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            color: customColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
