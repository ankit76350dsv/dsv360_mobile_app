import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;

  const CustomChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if(icon != null) Icon(icon, size: 16, color: color.withOpacity(0.7)),
          if(icon != null) const SizedBox(width: 4.0),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
