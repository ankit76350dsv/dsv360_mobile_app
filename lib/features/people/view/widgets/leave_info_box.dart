import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class LeaveInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const LeaveInfoBox({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: customColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: customColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 14.0)),
        ],
      ),
    );
  }
}

class LargeLeaveInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const LargeLeaveInfoBox({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: customColors.textPrimary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: customColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 14.0)),
          ],
        ),
      ),
    );
  }
}
