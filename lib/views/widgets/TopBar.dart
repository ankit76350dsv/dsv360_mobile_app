import 'dart:io';
import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onInfoTap;
  final IconData? actionIcon;

  const TopBar({
    super.key,
    required this.title,
    this.onBack,
    this.onInfoTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          /// Back button
          IconButton(
            splashRadius: 20,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: customColors.textPrimary,
          ),

          /// Title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: customColors.textPrimary,
              ),
            ),
          ),

          /// More / Info button
          IconButton(
            splashRadius: 20,
            onPressed: onInfoTap,
            icon: Icon(
              actionIcon ??
                  (Platform.isAndroid ? Icons.more_vert : Icons.more_horiz),
              size: 18,
            ),
            color: customColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
