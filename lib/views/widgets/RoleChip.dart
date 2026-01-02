
import 'package:flutter/material.dart';

class RoleChip extends StatelessWidget {
  final String text;

  const RoleChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Chip(
      label: Text(text, style: textTheme.bodyMedium?.copyWith(color: colors.primary)),
      backgroundColor: colors.primary.withOpacity(0.12),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colors.primary.withOpacity(0.4), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
