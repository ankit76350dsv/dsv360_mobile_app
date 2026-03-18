import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class ClientInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ClientInfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Row(
      children: [
        Icon(icon, size: 18, color: customColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: customColors.textSecondary, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
