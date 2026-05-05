import 'package:flutter/material.dart';

class AttendanceTile extends StatelessWidget {
  final String day;
  final String date;
  final String status;
  final Color statusColor;
  final bool highlight;

  const AttendanceTile({
    super.key,
    required this.day,
    required this.date,
    required this.status,
    required this.statusColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "General",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text("9:00 AM - 7:00 PM", style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
