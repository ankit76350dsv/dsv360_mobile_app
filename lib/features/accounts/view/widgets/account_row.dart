import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class AccountRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const AccountRow({super.key, required this.icon, required this.value});



  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;

    return Row(
      children: [
        Icon(icon, size: 18, color: customColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            softWrap: true,
            style: TextStyle(color: customColors.textSecondary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}