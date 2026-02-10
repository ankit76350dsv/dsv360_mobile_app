import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class CustomCardButton extends StatelessWidget {
  final Function() onTap;
  final IconData icon;
  final Color? color;
  const CustomCardButton({
    super.key, 
    required this.onTap, 
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color == null ? customColors.primary!.withValues(alpha: 0.1) : color!.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color ?? customColors.primary),
      ),
    );
  }
}
