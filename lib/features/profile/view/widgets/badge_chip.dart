import 'package:flutter/material.dart';

class BadgeChip extends StatelessWidget {
  final String label;
  final Color chipColor;
  final double height;

  const BadgeChip({
    super.key,
    required this.label,
    required this.chipColor,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = chipColor.withValues(alpha: 0.25);
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            decoration: BoxDecoration(
              color: chipColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.shield, size: 14, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFECECEC),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
