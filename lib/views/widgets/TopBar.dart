import 'dart:io';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onInfoTap;

  const TopBar({
    super.key,
    required this.title,
    this.onBack,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          /// Back button
          IconButton(
            splashRadius: 20,
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            ),
            color: Colors.white70,
          ),

          /// Title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),

          /// More / Info button
          IconButton(
            splashRadius: 20,
            onPressed: onInfoTap,
            icon: Icon(
              Platform.isAndroid
                  ? Icons.more_vert
                  : Icons.more_horiz,
              size: 18,
            ),
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}
