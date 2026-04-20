import 'package:flutter/material.dart';

class ProgressStat extends StatelessWidget {
  final String label;
  final Color color;

  const ProgressStat({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
