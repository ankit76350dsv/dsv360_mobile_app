import 'dart:io';
import 'package:flutter/material.dart';

/// --- Top bar widget (back button left, centered title, info ':' on right) ---
class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onInfoTap;

  const TopBar({required this.title, this.onBack, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      // keep visually minimal like your screenshot
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button (left)
          Positioned(
            left: 0,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              color: Colors.white70,
              splashRadius: 20,
            ),
          ),

          // Center title
          Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // more info inside a small circle on right
          Positioned(
            right: 4,
            child: GestureDetector(
                child: IconButton(
                  onPressed: onInfoTap,
                  icon: Icon(Platform.isAndroid ? Icons.more_vert : Icons.more_horiz,size: 18),
                  color: Colors.white70,
                  splashRadius: 20,
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
