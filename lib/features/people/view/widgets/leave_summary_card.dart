import 'package:flutter/material.dart';

class LeaveSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const LeaveSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 14.0, top: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: TextStyle(color: color)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
