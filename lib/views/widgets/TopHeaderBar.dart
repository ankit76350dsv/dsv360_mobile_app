import 'package:flutter/material.dart';

class TopHeaderBar extends StatelessWidget {
  final String heading;

  const TopHeaderBar({required this.heading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),

      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              textAlign: TextAlign.center,
              heading,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Balance the back button width
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
