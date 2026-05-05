import 'package:dsv360/features/profile/view/widgets/badge_chip.dart';
import 'package:flutter/material.dart';

class BadgesSection extends StatelessWidget {
  final String title;
  final List<BadgeChip> badges;
  final Color accentColor;
  final String? imagePath;

  const BadgesSection({
    super.key,
    required this.title,
    required this.badges,
    this.accentColor = const Color(0xFF1ED760),
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 6,
                      spacing: 0,
                      children: badges,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
